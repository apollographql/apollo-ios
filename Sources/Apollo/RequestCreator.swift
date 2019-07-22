import Foundation

// Helper struct to create requests independently of HTTP operations.
public struct RequestCreator {
  
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
  /// - Returns: The created `GraphQLMap`
  public static func requestBody<Operation: GraphQLOperation>(for operation: Operation, sendOperationIdentifiers: Bool = false) -> GraphQLMap {
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
  
  static func requestMultipartFormData<Operation: GraphQLOperation>(for operation: Operation, files: [GraphQLFile], sendOperationIdentifiers: Bool, serializationFormat: JSONSerializationFormat.Type) throws -> MultipartFormData {
    let formData = MultipartFormData()
    
    let fields = requestBody(for: operation, sendOperationIdentifiers: sendOperationIdentifiers)
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
      formData.appendPart(inputStream: $0.inputStream,
                          contentLength: $0.contentLength,
                          name: $0.fieldName,
                          contentType: $0.mimeType,
                          filename: $0.originalName)
    }
    
    return formData
  }
}
