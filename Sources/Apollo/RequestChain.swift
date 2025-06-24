import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

public struct RequestChainRetry<Request: GraphQLRequest>: Swift.Error {
  public let request: Request

  public init(
    request: Request,
  ) {
    self.request = request
  }
}

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

struct FetchBehavior {

  var shouldAttemptCacheRead: Bool

  var shouldAttemptCacheWrite: Bool

  private var shouldAttemptNetworkFetch: NetworkBehavior

  init(
    shouldAttemptCacheRead: Bool,
    shouldAttemptCacheWrite: Bool,
    shouldAttemptNetworkFetch: NetworkBehavior
  ) {
    self.shouldAttemptCacheRead = shouldAttemptCacheRead
    self.shouldAttemptCacheWrite = shouldAttemptCacheWrite
    self.shouldAttemptNetworkFetch = shouldAttemptNetworkFetch
  }

  enum NetworkBehavior {
    case never
    case always
    case onCacheFailure
  }

  func shouldFetchFromNetwork(hadSuccessfulCacheRead: Bool) -> Bool {
    switch self.shouldAttemptNetworkFetch {
    case .never:
      return false
    case .always:
      return true
    case .onCacheFailure:
      return !hadSuccessfulCacheRead
    }
  }
}

struct RequestChain<Request: GraphQLRequest>: Sendable {

  private let urlSession: any ApolloURLSession
  private let interceptorProvider: any InterceptorProvider
  private let store: ApolloStore
  private let fetchBehavior: FetchBehavior

  typealias Operation = Request.Operation
  typealias ResultStream = AsyncThrowingStream<GraphQLResult<Operation.Data>, any Error>

  /// Creates a chain with the given interceptor array.
  ///
  /// - Parameters:
  ///   - interceptors: The array of interceptors to use.
  ///   - callbackQueue: The `DispatchQueue` to call back on when an error or result occurs.
  ///   Defaults to `.main`.
  init(
    urlSession: any ApolloURLSession,
    interceptorProvider: any InterceptorProvider,
    store: ApolloStore,
    fetchBehavior: FetchBehavior,
  ) {
    self.urlSession = urlSession
    self.interceptorProvider = interceptorProvider
    self.store = store
    self.fetchBehavior = fetchBehavior
  }

  /// Kicks off the request from the beginning of the interceptor array.
  ///
  /// - Parameters:
  ///   - request: The request to send.
  func kickoff(
    request: Request
  ) -> ResultStream where Operation: GraphQLQuery {
    return doInRetryingAsyncThrowingStream(request: request) { request, continuation in
      let didYieldCacheData = try await handleCacheRead(request: request, continuation: continuation)

      if self.fetchBehavior.shouldFetchFromNetwork(hadSuccessfulCacheRead: didYieldCacheData) {
        try await kickoffRequestInterceptors(for: request, continuation: continuation)
      }
    }
  }

  func kickoff(
    request: Request
  ) -> ResultStream {
    return doInRetryingAsyncThrowingStream(request: request) { request, continuation in
      try await kickoffRequestInterceptors(for: request, continuation: continuation)
    }
  }

  private func doInRetryingAsyncThrowingStream(
    request: Request,
    _ body: @escaping @Sendable (Request, ResultStream.Continuation) async throws -> Void
  ) -> ResultStream {
    return AsyncThrowingStream { continuation in
      let task = Task {
        do {
          try await doHandlingRetries(request: request) { request in
            try await body(request, continuation)
          }

        } catch {
          continuation.finish(throwing: error)
        }

        continuation.finish()
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }

  private func doHandlingRetries(
    request: Request,
    _ body: @escaping @Sendable (Request) async throws -> Void
  ) async throws {
    do {
      try await body(request)

    } catch let error as RequestChainRetry<Request> {
      try await self.doHandlingRetries(request: error.request, body)
    }
  }

  private func handleCacheRead(
    request: Request,
    continuation: ResultStream.Continuation
  ) async throws -> Bool where Operation: GraphQLQuery {
    guard self.fetchBehavior.shouldAttemptCacheRead else {
      return false
    }

    do {
      let cacheInterceptor = self.interceptorProvider.cacheInterceptor(for: request)
      let cacheData = try await cacheInterceptor.readCacheData(from: self.store, request: request)
      continuation.yield(cacheData)
      return true

    } catch {
      if !self.fetchBehavior.shouldFetchFromNetwork(hadSuccessfulCacheRead: false) {
        throw error
      }
      return false
    }
  }

  private func kickoffRequestInterceptors(
    for initialRequest: Request,
    continuation: ResultStream.Continuation
  ) async throws {
    nonisolated(unsafe) var finalRequest: Request!
    var next: @Sendable (Request) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>> = { request in
      finalRequest = request
      return try await kickOffHTTPInterceptors(for: request)
    }

    let interceptors = self.interceptorProvider.graphQLInterceptors(for: initialRequest)

    for interceptor in interceptors.reversed() {
      let tempNext = next

      next = { request in
        try await interceptor.intercept(request: request, next: tempNext)
      }
    }

    let resultStream = try await next(initialRequest)

    var didEmitResult: Bool = false

    for try await result in resultStream.getResults() {
      try await writeToCacheIfNecessary(result: result, for: finalRequest)

      continuation.yield(result.result)
      didEmitResult = true
    }

    guard didEmitResult else {
      throw RequestChainError.noResults
    }
  }

  private func kickOffHTTPInterceptors(
    for initialRequest: Request
  ) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>> {
    nonisolated(unsafe) var finalRequest: Request!
    var next: @Sendable (Request) async throws -> InterceptorResultStream<HTTPResponse> = { request in
      finalRequest = request
      return try await executeNetworkFetch(request: request)
    }

    let interceptors = self.interceptorProvider.httpInterceptors(for: initialRequest)

    for interceptor in interceptors.reversed() {
      let tempNext = next

      next = { request in
        try await interceptor.intercept(request: request, next: tempNext)
      }
    }

    let httpResponseStream = try await next(initialRequest)

    let parsingInterceptor = self.interceptorProvider.responseParser(for: finalRequest)
    for try await httpResponse in httpResponseStream.getResults() {
      // Need to parse results here
    }
  }

  private func executeNetworkFetch(
    request: Request
  ) async throws -> InterceptorResultStream<HTTPResponse> {

    return InterceptorResultStream(
      stream: AsyncThrowingStream { continuation in
        let task = Task {
          do {
            let (chunks, response) = try await urlSession.chunks(for: request)

            guard let response = response as? HTTPURLResponse else {
              preconditionFailure()
#warning(
              "Throw error instead of precondition failure? Look into if it is possible for this to even occur."
              )
            }

            for try await chunk in chunks {
              continuation.yield(
                HTTPResponse(response: response, rawResponseChunk: chunk as! Data)
              )
            }

            continuation.finish()
          } catch {
            continuation.finish(throwing: error)
          }
        }

        continuation.onTermination = { _ in task.cancel() }
      }
    )
  }

  private func writeToCacheIfNecessary(
    result: InterceptorResult<Request.Operation>.ParsedResult,
    for request: Request
  ) async throws {
    guard let records = result.cacheRecords,
      result.result.source == .server,
      request.cachePolicy.shouldAttemptCacheWrite
    else {
      return
    }

    try await cacheInterceptor.writeCacheData(
      cacheRecords: records,
      for: request.operation,
      with: result.result
    )
  }
}
