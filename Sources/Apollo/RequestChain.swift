import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

public enum RequestChainError: Swift.Error, LocalizedError {
  case noResults

  public var errorDescription: String? {
    switch self {
    case .noResults:
      return
        "Request chain completed request with no results emitted. This can occur if the network returns a success response with no body content, or if an interceptor fails to pass on the emitted results"
    }
  }

}

public struct RequestChain<Request: GraphQLRequest>: Sendable {

  public struct Retry: Swift.Error {
    public let request: Request
    public let fetchBehavior: FetchBehavior

    public init(request: Request, fetchBehavior: FetchBehavior) {
      self.request = request
      self.fetchBehavior = fetchBehavior
    }
  }

  private let urlSession: any ApolloURLSession
  private let interceptorProvider: any InterceptorProvider
  private let store: ApolloStore

  public typealias ResultStream = AsyncThrowingStream<GraphQLResult<Operation.Data>, any Error>
  public typealias Operation = Request.Operation

  private struct RequestContext {
    var request: Request
    var fetchBehavior: FetchBehavior
    let shouldAttemptCacheWrite: Bool
  }

  /// Creates a chain with the given interceptor array.
  ///
  /// - Parameters: TODO
  public init(
    urlSession: any ApolloURLSession,
    interceptorProvider: any InterceptorProvider,
    store: ApolloStore
  ) {
    self.urlSession = urlSession
    self.interceptorProvider = interceptorProvider
    self.store = store

  }

  /// Kicks off the request from the beginning of the interceptor array.
  ///
  /// - Parameters:
  ///   - request: The request to send.
  ///   - fetchBehavior: The `FetchBehavior` to use for this request. Determines if fetching will include cache/network.
  ///   - shouldAttemptCacheWrite: Determines if the results of a network fetch should be written to the local cache.
  public func kickoff(
    request: Request,
    fetchBehavior: FetchBehavior,
    shouldAttemptCacheWrite: Bool
  ) -> ResultStream {
    let requestContext = RequestContext(
      request: request,
      fetchBehavior: fetchBehavior,
      shouldAttemptCacheWrite: shouldAttemptCacheWrite
    )

    return doInRetryingAsyncThrowingStream(requestContext: requestContext) { requestContext, continuation in
      #warning("TODO: Write unit test that cache only request gets sent through interceptors still.")
      try await kickoffRequestInterceptors(requestContext: requestContext, continuation: continuation)
    }
  }

  private func doInRetryingAsyncThrowingStream(
    requestContext: RequestContext,
    _ body: @escaping @Sendable (RequestContext, ResultStream.Continuation) async throws -> Void
  ) -> ResultStream {
    return AsyncThrowingStream.executingInAsyncTask { continuation in
      try await doHandlingRetries(requestContext: requestContext) { request in
        try await body(requestContext, continuation)
      }
    }
  }

  private func doHandlingRetries(
    requestContext: RequestContext,
    _ body: @escaping @Sendable (RequestContext) async throws -> Void
  ) async throws {
    do {
      try await body(requestContext)

    } catch let error as Retry {
      let retryRequestContext = RequestContext(
        request: error.request,
        fetchBehavior: error.fetchBehavior,
        shouldAttemptCacheWrite: requestContext.shouldAttemptCacheWrite
      )

      try await self.doHandlingRetries(requestContext: retryRequestContext, body)
    }
  }

  private func kickoffRequestInterceptors(
    requestContext: RequestContext,
    continuation: ResultStream.Continuation
  ) async throws {
    let initialRequest = requestContext.request
    let interceptors = self.interceptorProvider.graphQLInterceptors(for: initialRequest)

    // Setup next function to traverse interceptors
    nonisolated(unsafe) var finalRequestContext: RequestContext!
    var next: @Sendable (Request) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>> = {
      finalRequest in

      finalRequestContext = requestContext
      finalRequestContext.request = finalRequest

      return execute(requestContext: finalRequestContext)
    }

    for interceptor in interceptors.reversed() {
      let tempNext = next

      next = { request in
        try await interceptor.intercept(request: request, next: tempNext)
      }
    }

    // Kickoff first interceptor
    let resultStream = try await next(initialRequest)

    var didEmitResult: Bool = false

    for try await response in resultStream.getResults() {
      try Task.checkCancellation()

      try await writeToCacheIfNecessary(response: response, for: finalRequestContext)

      continuation.yield(response.result)
      didEmitResult = true
    }

    guard didEmitResult else {
      throw RequestChainError.noResults
    }
  }

  #warning("TODO: unit tests for cache read after failed network fetch")
  private func execute(
    requestContext: RequestContext
  ) -> InterceptorResultStream<GraphQLResponse<Operation>> {
    return InterceptorResultStream(
      stream: AsyncThrowingStream<GraphQLResponse<Operation>, any Error>.executingInAsyncTask { continuation in
        let fetchBehavior = requestContext.fetchBehavior
        var didYieldCacheData: Bool

        // If read from cache before network fetch
        if fetchBehavior.shouldReadFromCache(hadFailedNetworkFetch: false) {
          do {
            if let cacheResult = try await attemptCacheRead(request: requestContext.request) {
              // Successful cache read
              didYieldCacheData = true
              continuation.yield(
                GraphQLResponse<Request.Operation>(result: cacheResult, cacheRecords: nil)
              )
            }

            // Cache miss
            didYieldCacheData = false

          } catch {
            #warning(
              """
              TODO: If we are making cache miss return nil (instead of throwing error), then should
              this just always be throwing the error? What's the point of differentiating cache miss 
              from thrown error if we are still supressing it here?

              An error interceptor can still catch on the error and run a retry with a fetch behavior that doesn't do a cache read on the cache failure
              """
            )
            // Cache read failure
            if !fetchBehavior.shouldFetchFromNetwork(hadSuccessfulCacheRead: false) {
              throw error
            } else {
              didYieldCacheData = false
            }
          }
        }

        // If should perform network fetch (based on cache result)
        if fetchBehavior.shouldFetchFromNetwork(hadSuccessfulCacheRead: didYieldCacheData) {
          do {
            let networkStream = try await kickOffHTTPInterceptors(requestContext: requestContext)
            try await continuation.passthroughResults(of: networkStream.getResults())

            // Successful network fetch -> Finished

          } catch {
            // Network fetch throws error
            if fetchBehavior.shouldReadFromCache(hadFailedNetworkFetch: true) {
              // Attempt recovery with cache read
              if let cacheResult = try await attemptCacheRead(request: requestContext.request) {
                // Successful cache read
                continuation.yield(
                  GraphQLResponse<Request.Operation>(result: cacheResult, cacheRecords: nil)
                )
              }

            } else {
              throw error
            }
          }
        }
      }
    )
  }

  private func attemptCacheRead(
    request: Request
  ) async throws -> GraphQLResult<Operation.Data>? {
    let cacheInterceptor = self.interceptorProvider.cacheInterceptor(for: request)
    return try await cacheInterceptor.readCacheData(from: self.store, request: request)
  }

  private func kickOffHTTPInterceptors(
    requestContext: RequestContext
  ) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>> {
    let graphQLRequest = requestContext.request
    let interceptors = self.interceptorProvider.httpInterceptors(for: graphQLRequest)

    // Setup next function to traverse interceptors
    var next: @Sendable (URLRequest) async throws -> HTTPResponse = { request in
      return try await executeNetworkFetch(request: request)
    }

    for interceptor in interceptors.reversed() {
      let tempNext = next

      next = { request in
        try await interceptor.intercept(request: request, next: tempNext)
      }
    }

    // Kickoff first HTTP interceptor
    let httpResponse = try await next(graphQLRequest.toURLRequest())

    let parsingInterceptor = self.interceptorProvider.responseParser(for: graphQLRequest)

    return try await parsingInterceptor.parse(
      response: httpResponse,
      for: graphQLRequest,
      includeCacheRecords: requestContext.shouldAttemptCacheWrite
    )
  }

  private func executeNetworkFetch(
    request: URLRequest
  ) async throws -> HTTPResponse {
    let (chunks, response) = try await urlSession.chunks(for: request)

    guard let response = response as? HTTPURLResponse else {
      preconditionFailure()
    }

    return HTTPResponse(response: response, chunks: InterceptorResultStream(stream: chunks))
  }

  private func writeToCacheIfNecessary(
    response: GraphQLResponse<Request.Operation>,
    for requestContext: RequestContext
  ) async throws {
    guard requestContext.shouldAttemptCacheWrite,
      response.cacheRecords != nil,
      response.result.source == .server
    else {
      return
    }

    let cacheInterceptor = self.interceptorProvider.cacheInterceptor(for: requestContext.request)
    try await cacheInterceptor.writeCacheData(
      to: self.store,
      request: requestContext.request,
      response: response
    )
  }
}

// MARK: - FetchBehavior Helpers

extension FetchBehavior {

  fileprivate func shouldReadFromCache(hadFailedNetworkFetch: Bool) -> Bool {
    switch self.cacheRead {
    case .never:
      return false
    case .beforeNetworkFetch:
      return !hadFailedNetworkFetch
    case .onNetworkFailure:
      return hadFailedNetworkFetch
    }
  }

  fileprivate func shouldFetchFromNetwork(hadSuccessfulCacheRead: Bool) -> Bool {
    switch self.networkFetch {
    case .never:
      return false
    case .always:
      return true
    case .onCacheMiss:
      return !hadSuccessfulCacheRead
    }
  }

}
