import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A request chain defines a sequence of interceptors that handle the lifecycle of a particular
/// GraphQL operation's execution. One interceptor might add custom HTTP headers to a request,
/// while the next might be responsible for actually sending the request to a GraphQL server over
/// HTTP. A third interceptor might then write the operation's result to the cache.
///
/// When an operation is executed an object called an `InterceptorProvider` generates a RequestChain
/// for the operation. Then `kickoff` is called on the request chain, which runs the first
/// interceptor in the chain.
///
/// An interceptor can perform arbitrary, asynchronous logic on any thread. When an interceptor
/// finishes running, it calls `proceedAsync` on its `RequestChain`, which advances to the next
/// interceptor.
///
/// By default when the last interceptor in the chain finishes, if a parsed operation result is
/// available, that result is returned to the operation's original caller. Otherwise, error-handling
/// logic is called.
public protocol RequestChain: Cancellable {
  func kickoff<Operation>(
    request: HTTPRequest<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  func proceedAsync<Operation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation

  func cancel()

  func terminate()

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
