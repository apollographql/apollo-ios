import Foundation

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

      let hash: String
      if operation.operationDefinition == operation.queryDocument {
        // The codegen had everything it needed to generate the hash
        hash = operationIdentifier
      } else {
        // The codegen needed more info for the correct hash - regenerate it.
        hash = operation.queryDocument.sha256Hash
      }

      body["extensions"] = [
        "persistedQuery" : ["sha256Hash": hash, "version": 1]
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
    let fieldsForFiles = Set(files.map { $0.fieldName })
    var fields = requestBody(for: operation, sendOperationIdentifiers: sendOperationIdentifiers)
    var variables = fields["variables"] as? GraphQLMap ?? GraphQLMap()
    for fieldName in fieldsForFiles {
      if
        let value = variables[fieldName],
        let arrayValue = value as? [JSONEncodable] {
        let updatedArray: [JSONEncodable?] = arrayValue.map { _ in nil }
          variables.updateValue(updatedArray, forKey: fieldName)
      } else {
        variables.updateValue(nil, forKey: fieldName)
      }
    }
    fields["variables"] = variables

    let operationData = try serializationFormat.serialize(value: fields)
    formData.appendPart(data: operationData, name: "operations")

    var map = [String: [String]]()
    if files.count == 1 {
      let firstFile = files.first!
      map["0"] = ["variables.\(firstFile.fieldName)"]
    } else {
      for (index, file) in files.enumerated() {
        map["\(index)"] = ["variables.\(file.fieldName).\(index)"]
      }
    }

    let mapData = try serializationFormat.serialize(value: map)
    formData.appendPart(data: mapData, name: "map")

    for (index, file) in files.enumerated() {
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
