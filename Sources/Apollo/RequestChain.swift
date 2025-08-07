import Foundation
import ApolloAPI

public struct RequestChain<Request: GraphQLRequest>: Sendable {

  public struct Retry: Swift.Error {
    /// The request to be retried.
    public let request: Request

    public init(request: Request) {
      self.request = request
    }
  }

  private let urlSession: any ApolloURLSession
  private let interceptors: Interceptors
  private let store: ApolloStore

  public typealias ResultStream = AsyncThrowingStream<GraphQLResponse<Operation>, any Error>
  public typealias Operation = Request.Operation

  /// Creates a chain with the given interceptor array.
  ///
  /// - Parameters: TODO
  public init(
    urlSession: any ApolloURLSession,
    interceptors: Interceptors,
    store: ApolloStore
  ) {
    self.urlSession = urlSession
    self.interceptors = interceptors
    self.store = store

  }

  /// Kicks off the request from the beginning of the interceptor array.
  ///
  /// - Parameters:
  ///   - request: The request to send.
  ///   - fetchBehavior: The ``FetchBehavior`` to use for this request. Determines if fetching will include cache/network.
  ///   - shouldAttemptCacheWrite: Determines if the results of a network fetch should be written to the local cache.
  public func kickoff(
    request: Request
  ) -> ResultStream {
    return doInRetryingAsyncThrowingStream(request: request) { request, continuation in
      try await kickoffRequestInterceptors(request: request, continuation: continuation)
    }
  }

  private func doInRetryingAsyncThrowingStream(
    request: Request,
    _ body: @escaping @Sendable (Request, ResultStream.Continuation) async throws -> Void
  ) -> ResultStream {
    return AsyncThrowingStream.executingInAsyncTask { continuation in
      try await doHandlingRetries(request: request) { request in
        try await body(request, continuation)
      }
    }
  }

  private func doHandlingRetries(
    request: Request,
    _ body: @escaping @Sendable (Request) async throws -> Void
  ) async throws {
    do {
      try await body(request)

    } catch let error as Retry {
      try await self.doHandlingRetries(request: error.request, body)
    }
  }

  private func kickoffRequestInterceptors(
    request initialRequest: Request,
    continuation: ResultStream.Continuation
  ) async throws {
    let interceptors = self.interceptors.graphQL

    // Setup next function to traverse interceptors
    nonisolated(unsafe) var finalRequest: Request!
    var next: @Sendable (Request) async -> InterceptorResultStream<Request> = {
      request in
      finalRequest = request

      return execute(request: request)
    }

    for interceptor in interceptors.reversed() {
      let tempNext = next

      next = { request in
        do {
          return try await interceptor.intercept(request: request, next: tempNext)

        } catch {
          return InterceptorResultStream<Request>(stream: .init(unfolding: {
            throw error
          }))
        }
      }
    }

    // Kickoff first interceptor
    let resultStream = await next(initialRequest)

    var didEmitResult: Bool = false

    for try await response in resultStream.getStream() {
      try Task.checkCancellation()

      try await writeToCacheIfNecessary(response: response, for: finalRequest)

      continuation.yield(response.result)
      didEmitResult = true
    }

    guard didEmitResult else {
      throw ApolloClient.Error.noResults
    }
  }
  
  private func execute(
    request: Request
  ) -> InterceptorResultStream<Request> {
    return InterceptorResultStream<Request>(
      stream: AsyncThrowingStream<ParsedResult<Operation>, any Error>.executingInAsyncTask { continuation in
        let fetchBehavior = request.fetchBehavior
        var didYieldCacheData: Bool = false

        // If read from cache before network fetch
        if fetchBehavior.shouldReadFromCache(hadFailedNetworkFetch: false) {
          do {
            if let cacheResult = try await attemptCacheRead(request: request) {
              // Successful cache read
              didYieldCacheData = true
              continuation.yield(
                ParsedResult<Request.Operation>(result: cacheResult, cacheRecords: nil)
              )
            }

            // Cache miss

          } catch {            
            // Cache read failure
            if !fetchBehavior.shouldFetchFromNetwork(hadSuccessfulCacheRead: false) {
              throw error
            }
          }
        }

        // If should perform network fetch (based on cache result)
        if fetchBehavior.shouldFetchFromNetwork(hadSuccessfulCacheRead: didYieldCacheData) {
          do {
            let networkStream = try await kickOffHTTPInterceptors(request: request)
            try await continuation.passthroughResults(of: networkStream.getStream())

            // Successful network fetch -> Finished

          } catch {
            // Network fetch throws error
            if fetchBehavior.shouldReadFromCache(hadFailedNetworkFetch: true) {
              // Attempt recovery with cache read
              if let cacheResult = try await attemptCacheRead(request: request) {
                // Successful cache read
                continuation.yield(
                  ParsedResult<Request.Operation>(result: cacheResult, cacheRecords: nil)
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
  ) async throws -> GraphQLResponse<Operation>? {
    let cacheInterceptor = self.interceptors.cache
    return try await cacheInterceptor.readCacheData(from: self.store, request: request)
  }

  private func kickOffHTTPInterceptors(
    request graphQLRequest: Request
  ) async throws -> InterceptorResultStream<Request> {
    let interceptors = self.interceptors.http

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

    let parsingInterceptor = self.interceptors.parser

    return try await parsingInterceptor.parse(
      response: httpResponse,
      for: graphQLRequest,
      includeCacheRecords: graphQLRequest.writeResultsToCache
    )
  }

  private func executeNetworkFetch(
    request: URLRequest
  ) async throws -> HTTPResponse {
    let (chunks, response) = try await urlSession.chunks(for: request)

    guard let response = response as? HTTPURLResponse else {
      preconditionFailure()
    }

    return HTTPResponse(response: response, chunks: NonCopyableAsyncThrowingStream(stream: chunks))
  }

  private func writeToCacheIfNecessary(
    response: ParsedResult<Request.Operation>,
    for request: Request
  ) async throws {
    guard request.writeResultsToCache,
      response.cacheRecords != nil,
      response.result.source == .server
    else {
      return
    }

    let cacheInterceptor = self.interceptors.cache
    try await cacheInterceptor.writeCacheData(
      to: self.store,
      request: request,
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
