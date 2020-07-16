import Foundation
#if !COCOAPODS
import ApolloCore
#endif

public protocol RequestCreator {
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
  /// - Returns: The created `GraphQLMap`
  func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                sendOperationIdentifiers: Bool,
                                                sendQueryDocument: Bool,
                                                autoPersistQuery: Bool) -> GraphQLMap

  /// Creates multi-part form data to send with a request
  ///
  /// - Parameters:
  ///   - operation: The operation to create the data for.
  ///   - files: An array of files to use.
  ///   - sendOperationIdentifiers: True if operation identifiers should be sent, false if not.
  ///   - serializationFormat: The format to use to serialize data.
  ///   - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise.
  /// - Returns: The created form data
  /// - Throws: Errors creating or loading the form  data
  func requestMultipartFormData<Operation: GraphQLOperation>(for operation: Operation,
                                                             files: [GraphQLFile],
                                                             sendOperationIdentifiers: Bool,
                                                             serializationFormat: JSONSerializationFormat.Type,
                                                             manualBoundary: String?) throws -> MultipartFormData
}

extension RequestCreator {
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
  ///   - sendQueryDocument: Whether or not to send the full query document. Defaults to true.
  ///   - autoPersistQuery: Whether to use auto-persisted query information. Defaults to false.
  /// - Returns: The created `GraphQLMap`
  public func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                       sendOperationIdentifiers: Bool = false,
                                                       sendQueryDocument: Bool = true,
                                                       autoPersistQuery: Bool = false) -> GraphQLMap {
    var body: GraphQLMap = [
      "variables": operation.variables,
      "operationName": operation.operationName,
    ]

    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }

      body["id"] = operationIdentifier
    }

    if sendQueryDocument {
      body["query"] = operation.queryDocument
    }

    if autoPersistQuery {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To enable `autoPersistQueries`, Apollo types must be generated with operationIdentifiers")
      }

      body["extensions"] = [
        "persistedQuery" : ["sha256Hash": operationIdentifier, "version": 1]
      ]
    }

    return body
  }

  /// Creates multi-part form data to send with a request
  ///
  /// - Parameters:
  ///   - operation: The operation to create the data for.
  ///   - files: An array of files to use.
  ///   - sendOperationIdentifiers: True if operation identifiers should be sent, false if not.
  ///   - serializationFormat: The format to use to serialize data.
  ///   - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise.
  /// - Returns: The created form data
  /// - Throws: Errors creating or loading the form  data
  public func requestMultipartFormData<Operation: GraphQLOperation>(for operation: Operation,
                                                                    files: [GraphQLFile],
                                                                    sendOperationIdentifiers: Bool,
                                                                    serializationFormat: JSONSerializationFormat.Type,
                                                                    manualBoundary: String?) throws -> MultipartFormData {
    let formData: MultipartFormData

    if let boundary = manualBoundary {
      formData = MultipartFormData(boundary: boundary)
    } else {
      formData = MultipartFormData()
    }

    // Make sure all fields for files are set to null, or the server won't look
    // for the files in the rest of the form data
    let fieldsForFiles = Set(files.map { $0.fieldName }).sorted()
    var fields = requestBody(for: operation, sendOperationIdentifiers: sendOperationIdentifiers)
    var variables = fields["variables"] as? GraphQLMap ?? GraphQLMap()
    for fieldName in fieldsForFiles {
      if
        let value = variables[fieldName],
        let arrayValue = value as? [JSONEncodable] {
        let arrayOfNils: [JSONEncodable?] = arrayValue.map { _ in nil }
          variables.updateValue(arrayOfNils, forKey: fieldName)
      } else {
        variables.updateValue(nil, forKey: fieldName)
      }
    }
    fields["variables"] = variables

    let operationData = try serializationFormat.serialize(value: fields)
    formData.appendPart(data: operationData, name: "operations")

    // If there are multiple files for the same field, make sure to include them with indexes for the field. If there are multiple files for different fields, just use the field name.
    var map = [String: [String]]()
    var currentIndex = 0
    
    var sortedFiles = [GraphQLFile]()
    for fieldName in fieldsForFiles {
      let filesForField = files.filter { $0.fieldName == fieldName }
      if filesForField.count == 1 {
        let firstFile = filesForField.first!
        map["\(currentIndex)"] = ["variables.\(firstFile.fieldName)"]
        sortedFiles.append(firstFile)
        currentIndex += 1
      } else {
        for (index, file) in filesForField.enumerated() {
          map["\(currentIndex)"] = ["variables.\(file.fieldName).\(index)"]
          sortedFiles.append(file)
          currentIndex += 1
        }
      }
    }
    
    assert(sortedFiles.count == files.count, "Number of sorted files did not equal the number of incoming files - some field name has been left out.")

    let mapData = try serializationFormat.serialize(value: map)
    formData.appendPart(data: mapData, name: "map")

    for (index, file) in sortedFiles.enumerated() {
      formData.appendPart(inputStream: try file.generateInputStream(),
                          contentLength: file.contentLength,
                          name: "\(index)",
                          contentType: file.mimeType,
                          filename: file.originalName)
    }

    return formData
  }
}

// Helper struct to create requests independently of HTTP operations.
public struct ApolloRequestCreator: RequestCreator {
  // Internal init methods cannot be used in public methods
  public init() { }
}
