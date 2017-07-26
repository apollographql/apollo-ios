/// A network transport is responsible for sending GraphQL operations to a server.
public protocol NetworkTransport {
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  func send<Operation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - files: A list of files to send as a multipart request.
  ///   - progressHandler: A closure to call periodically as the request is sent.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  func upload<Operation: GraphQLOperation>(operation: Operation, files: [GraphQLFile]?, progressHandler: ((Progress) -> Void)?, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable
}

public extension NetworkTransport {
  func upload<Operation: GraphQLOperation>(operation: Operation, files: [GraphQLFile]? = nil, progressHandler: ((Progress) -> Void)? = nil, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    fatalError("NetworkTransport.upload(operation:files:progressHandler:completionHandler) not implemented.")
  }
}
