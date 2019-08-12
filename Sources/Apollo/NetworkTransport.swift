/// A network transport is responsible for sending GraphQL operations to a server.
public protocol NetworkTransport {
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred.
  /// - Returns: An object that can be used to cancel an in progress request.
  func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
}

/// A network transport which can also handle uploads of files.
public protocol UploadingNetworkTransport: NetworkTransport {
  
  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - completionHandler: The completion handler to execute when the request completes or errors
  /// - Returns: An object that can be used to cancel an in progress request.
  func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
}
