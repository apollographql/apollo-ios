import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public protocol RequestChain: Cancellable {
  func kickoff<Operation>(
    request: HTTPRequest<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  @available(*, deprecated, renamed: "proceedAsync(request:response:interceptor:completion:)")
  func proceedAsync<Operation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  func proceedAsync<Operation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    interceptor: any ApolloInterceptor,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  func cancel()

  func retry<Operation>(
    request: HTTPRequest<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  func handleErrorAsync<Operation>(
    _ error: Error,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  func returnValueAsync<Operation>(
    for request: HTTPRequest<Operation>,
    value: GraphQLResult<Operation.Data>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  var isCancelled: Bool { get }
}
