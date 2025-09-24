import Foundation
import ApolloAPI

/// Manages a chain of steps taken to execute a ``GraphQLRequest``. ``RequestChain`` enables customization of each step
/// of a request by injection of ``Interceptors``.
///
/// ## Custom Functionality via Interceptors
/// The ``RequestChain`` allows complete control over the execution of a request. It manages the flow of data through
/// a series of steps, but the implementation logic for each step can be controlled by using custom interceptors.
/// You can control the logic of cache reads/writes (via ``CacheInterceptor``), networking (via ``ApolloURLSession``),
/// and response parsing/GraphQL execution (via ``ResponseParsingInterceptor``). The ``RequestChain`` also provides
/// the ability to add additional behaviors by inspecting and/or mutating the ``GraphQLRequest`` and ``GraphQLResponse``
/// (via ``GraphQLInterceptor``s), and the ``HTTPResponse`` and raw `Data` stream (via ``HTTPInterceptor``s).
///
/// ## Response Streams
/// Because some requests may have a multi-part response, such as subscriptions or operations using `@defer`, the
/// results of a ``RequestChain`` are processed through ``NonCopyableAsyncThrowingStream``s. Interceptors may use the
/// mapping functions of these streams to inspect and/or mutate the resulting elements. The transformed results
/// returned from the mapping functions will be passed to the next step in the chain for each element. For requests
/// that should have a single response, these streams will emit a single value and then terminate.
///
/// ## Request Chain Flow
/// The ``RequestChain`` sends a request "down" the chain of it's interceptors, executes the request, and then sends
/// the result back "up" through the chain. This means the first interceptor will receive the request first and the
/// response last.
///
/// When ``RequestChain/kickoff(request:)`` is called, the ``RequestChain`` processes the request through each of its
/// interceptors using the following process:
///
/// **1. GraphQL Interceptors (Pre-flight)**
///
/// The ``GraphQLRequest`` is passed "down" through the ``GraphQLInterceptor``s in sequential order. Each interceptor may
/// inspect and/or mutate the request and proceeds by calling the provided `next` closure.
///
/// **2. Cache Read**
///
/// The ``RequestChain`` uses the ``GraphQLRequest/fetchBehavior`` of the request to determine if a pre-flight cache
/// read is necessary. If so, it attempts a cache read by calling the provided ``CacheInterceptor``'s
/// ``CacheInterceptor/readCacheData(from:request:)`` function.
///
/// **3. URLRequest Creation**
///
/// The ``RequestChain`` uses the ``GraphQLRequest/fetchBehavior`` of the request to determine if a network fetch should
/// be executed. If so, it calls ``GraphQLRequest``.``GraphQLRequest/toURLRequest()`` to convert the request into a
/// `URLRequest`.
///
/// **4. HTTP Interceptors (Pre-flight)**
///
/// The `URLRequest` is passed "down" through the ``HTTPInterceptor``s in sequential order. Each interceptor may inspect
/// and/or mutate the request and proceeds by calling the provided `next` closure.
///
/// **5. Network Fetch**
///
/// The `URLRequest` is passed to the provided `urlSession`'s ``ApolloURLSession/chunks(for:)`` for fetching via
/// the network.
///
/// **6. HTTP Interceptors (Post-flight)**
///
/// The received ``HTTPResponse`` is passed back "up" through the ``HTTPInterceptor``s in reverse order, starting with the
/// last interceptor and ending with the first. As ``HTTPResponse/chunks`` are received by the stream, each
/// ``HTTPInterceptor`` may inspect and/or mutate the raw response `Data` before proceeding.
///
/// **7. Response Parsing**
///
/// The ``HTTPResponse`` is passed to the provided ``ResponseParsingInterceptor``, which parses the stream of
/// ``HTTPResponse/chunks`` as they are received and returns an ``InterceptorResultStream`` which emits
/// ``ParsedResult``s as each chunk is parsed.
///
/// **8. GraphQL Interceptors (Post-flight)**
///
/// The ``InterceptorResultStream`` is passed back "up" through the ``GraphQLInterceptor``s in reverse order, starting
/// with the last interceptor and ending with the first. As ``ParsedResult``s are received by the stream, each
/// ``GraphQLInterceptor`` may inspect and/or mutate the result before proceeding.
///
/// **9. Cache Write**
///
/// The ``RequestChain`` uses the ``GraphQLRequest/fetchBehavior`` of the request to determine if a cache write
/// should be performed. If so, it attempts a cache write by calling the provided ``CacheInterceptor``'s
/// ``CacheInterceptor/writeCacheData(to:request:response:)`` function.
///
/// **10. Return a ResultStream**
///
/// The final ``GraphQLResponse`` values of the ``ParsedResult``.``ParsedResult/result`` emitted by the
/// ``InterceptorResultStream`` are returned as an `AsyncThrowingStream` to the caller.
public struct RequestChain<Request: GraphQLRequest>: Sendable {

  /// An error that can be thrown by a component of a ``RequestChain`` to indicate that the request should be retried.
  ///
  /// When a ``RequestChain`` receives a thrown ``Retry`` error, it will restart from step 1 of the
  /// [Request Chain Flow](<doc:RequestChain#Request-Chain-Flow>) using the ``Retry/request`` provided by the error.
  /// This allows the request to be modified to correct errors that may be causing the failure prior to beginning again.
  ///
  /// - Note: On a retry, the ``RequestChain`` uses the same ``Interceptors``, ``ApolloURLSession``, and ``ApolloStore``
  ///  as the initial request. This means that interceptors will retain their state between retries of the same request.
  ///
  /// ## Retry Loop Prevention
  /// If a retried request continues to fail, an interceptor which throws a ``Retry`` error may continue to throw a
  /// ``Retry`` error again. This could lead to an infinite loop where a failing request continuously retries forever.
  ///  To prevent this, we provide a ``MaxRetryInterceptor`` that throws a ``MaxRetryInterceptor/MaxRetriesError`` if a
  /// maximum number of retries have been performed. The ``DefaultInterceptorProvider`` contains a
  /// ``MaxRetryInterceptor`` with a default of 3 retries allowed.
  ///
  /// - Important: When creating a custom ``InterceptorProvider`` it is highly recommended that you include a
  /// ``MaxRetryInterceptor`` early on in the chain.
  ///
  /// If you are not using a ``MaxRetryInterceptor`` or similar mechanism, you must ensure that any interceptor that
  /// throws a ``Retry`` error maintains state that ensures it does not continue to trigger retries infinitely.
  public struct Retry: Swift.Error {
    /// The request to be retried
    public let request: Request

    /// Designated initializer
    /// - Parameter request: The request to be retried
    public init(request: Request) {
      self.request = request
    }
  }

  private let urlSession: any ApolloURLSession
  private let interceptors: Interceptors
  private let store: ApolloStore

  public typealias ResultStream = AsyncThrowingStream<GraphQLResponse<Request.Operation>, any Error>

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - urlSession: The ``ApolloURLSession`` to use when making network calls for the request
  ///   - interceptors: The interceptors that the request chain should call during the
  ///   [Request Chain Flow](<doc:RequestChain#Request-Chain-Flow>)
  ///   - store: The ``ApolloStore`` to be used for cache reads/writes. This store will be passed to the
  ///   ``CacheInterceptor`` functions when performing cache operations.
  public init(
    urlSession: any ApolloURLSession,
    interceptors: Interceptors,
    store: ApolloStore
  ) {
    self.urlSession = urlSession
    self.interceptors = interceptors
    self.store = store

  }

  /// Kicks off a request from step 1 of the [Request Chain Flow](<doc:RequestChain#Request-Chain-Flow>).
  ///
  /// - Parameter request: The ``GraphQLRequest`` to kick off
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
      stream: AsyncThrowingStream<ParsedResult<Request.Operation>, any Error>.executingInAsyncTask { continuation in
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
  ) async throws -> GraphQLResponse<Request.Operation>? {
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
