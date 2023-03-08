#if !COCOAPODS
import ApolloAPI
#endif

/// A custom implementation of RequestChain that wraps an ApolloInterceptor instance to provide
/// re-entrant behaviour to the request chain. This is required for the request chain to support
/// network flows such as GraphQL Subscriptions where interceptors can call back into the request
/// chain multiple times.
class ApolloInterceptorReentrantWrapper: RequestChain {
  @Atomic var isCancelled: Bool = false

  let wrappedInterceptor: ApolloInterceptor
  let requestChain: Unmanaged<InterceptorRequestChain>
  let index: Int

  init(
    interceptor: ApolloInterceptor,
    requestChain: Unmanaged<InterceptorRequestChain>,
    index: Int
  ) {
    self.wrappedInterceptor = interceptor
    self.requestChain = requestChain
    self.index = index
  }

  func kickoff<Operation>(
    request: HTTPRequest<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {
    requestChain.takeUnretainedValue().kickoff(request: request, completion: completion)
  }

  func proceedAsync<Operation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {
    requestChain.takeUnretainedValue().proceedAsync(
      request: request,
      response: response,
      completion: completion,
      interceptor: self
    )
  }

  func cancel() {
    guard !self.isCancelled else {
      // Do not proceed, this chain has been cancelled.
      return
    }

    self.$isCancelled.mutate { $0 = true }

    if let cancellableInterceptor = wrappedInterceptor as? Cancellable {
      cancellableInterceptor.cancel()
    }

    requestChain.takeUnretainedValue().cancel()
  }

  func retry<Operation>(
    request: HTTPRequest<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {
    requestChain.takeUnretainedValue().retry(request: request, completion: completion)
  }

  func handleErrorAsync<Operation>(
    _ error: Error,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {
    requestChain.takeUnretainedValue().handleErrorAsync(
      error,
      request: request,
      response: response,
      completion: completion
    )
  }

  func returnValueAsync<Operation>(
    for request: HTTPRequest<Operation>,
    value: GraphQLResult<Operation.Data>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {
    requestChain.takeUnretainedValue().returnValueAsync(
      for: request,
      value: value,
      completion: completion
    )
  }
}

extension ApolloInterceptorReentrantWrapper : ApolloInterceptor {
  func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : ApolloAPI.GraphQLOperation {
    wrappedInterceptor.interceptAsync(
      chain: self,
      request: request,
      response: response,
      completion: completion
    )
  }
}
