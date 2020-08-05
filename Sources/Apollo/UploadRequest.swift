import Foundation

public class UploadRequest<Operation: GraphQLOperation>: HTTPRequest<Operation> {
  
  public let requestCreator: RequestCreator
  public let files: [GraphQLFile]
  public let manualBoundary: String?
  
  public let serializationFormat = JSONSerializationFormat.self
  
  public init(graphQLEndpoint: URL,
              operation: Operation,
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
               additionalHeaders: additionalHeaders)

  }
  
  public override func toURLRequest() throws -> URLRequest {
    let shouldSendOperationID = (operation.operationIdentifier != nil)
    
    let formData = try requestCreator.requestMultipartFormData(for: self.operation,
                                                               files: self.files,
                                            sendOperationIdentifiers: shouldSendOperationID,
                                            serializationFormat: self.serializationFormat,
                                            manualBoundary: self.manualBoundary)
    self.contentType = "multipart/form-data; boundary=\(formData.boundary)"
    var request = try super.toURLRequest()
    request.httpBody = try formData.encode()
    
    return request
  }
}
