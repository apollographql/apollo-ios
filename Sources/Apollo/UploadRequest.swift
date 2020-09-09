import Foundation

/// A request class allowing for a multipart-upload request.
public class UploadRequest<Operation: GraphQLOperation>: HTTPRequest<Operation> {
  
  public let requestCreator: RequestCreator
  public let files: [GraphQLFile]
  public let manualBoundary: String?
  
  public let serializationFormat = JSONSerializationFormat.self
  
  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - operation: The GraphQL Operation to execute
  ///   - clientName: The name of the client to send with the `"apollographql-client-name"` header
  ///   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  ///   - additionalHeaders: Any additional headers you wish to add by default to this request. Defaults to an empty dictionary.
  ///   - files: The array of files to upload for all `Upload` parameters in the mutation.
  ///   - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise. Defaults to nil.
  ///   - requestCreator: An object conforming to the `RequestCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestCreator` implementation.
  public init(graphQLEndpoint: URL,
              operation: Operation,
              clientName: String,
              clientVersion: String,
              additionalHeaders: [String: String] = [:],
              files: [GraphQLFile],
              manualBoundary: String? = nil,
              requestCreator: RequestCreator = ApolloRequestCreator()) {
    self.requestCreator = requestCreator
    self.files = files
    self.manualBoundary = manualBoundary
    super.init(graphQLEndpoint: graphQLEndpoint,
               operation: operation,
               contentType: "multipart/form-data",
               clientName: clientName,
               clientVersion: clientVersion,
               additionalHeaders: additionalHeaders)
  }
  
  public override func toURLRequest() throws -> URLRequest {
    let shouldSendOperationID = (operation.operationIdentifier != nil)
    
    let formData = try requestCreator.requestMultipartFormData(for: self.operation,
                                                               files: self.files,
                                            sendOperationIdentifiers: shouldSendOperationID,
                                            serializationFormat: self.serializationFormat,
                                            manualBoundary: self.manualBoundary)
    self.updateContentType(to: "multipart/form-data; boundary=\(formData.boundary)")
    var request = try super.toURLRequest()
    request.httpBody = try formData.encode()
    request.httpMethod = GraphQLHTTPMethod.POST.rawValue
    
    return request
  }
}
