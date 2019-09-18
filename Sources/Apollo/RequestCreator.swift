import Foundation

public protocol RequestCreator {
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
  /// - Returns: The created `GraphQLMap`
  func requestBody<Operation: GraphQLOperation>(for operation: Operation, sendOperationIdentifiers: Bool) -> GraphQLMap

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
  /// - Returns: The created `GraphQLMap`
  public func requestBody<Operation: GraphQLOperation>(for operation: Operation, sendOperationIdentifiers: Bool = false) -> GraphQLMap {
    var body: GraphQLMap = [
      "variables": operation.variables,
      "operationName": operation.operationName,
    ]

    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }

      body["id"] = operationIdentifier
    } else {
      body["query"] = operation.queryDocument
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
                                                                    manualBoundary: String? = nil) throws -> MultipartFormData {
    let formData: MultipartFormData

    if let boundary = manualBoundary {
      formData = MultipartFormData(boundary: boundary)
    } else {
      formData = MultipartFormData()
    }

    let fields = requestBody(for: operation)
    for (name, data) in fields {
      if let data = data as? GraphQLMap {
        let data = try serializationFormat.serialize(value: data)
        formData.appendPart(data: data, name: name)
      } else if let data = data as? String {
        try formData.appendPart(string: data, name: name)
      } else {
        try formData.appendPart(string: data.debugDescription, name: name)
      }
    }

    files.forEach {
      formData.appendPart(inputStream: $0.inputStream, contentLength: $0.contentLength, name: $0.fieldName, contentType: $0.mimeType, filename: $0.originalName)
    }

    return formData
  }
}

// Helper struct to create requests independently of HTTP operations.
public struct ApolloRequestCreator: RequestCreator {
  // Internal init methods cannot be used in public methods
  public init() { }
}
