import Foundation

/// A protocol for an interceptor in a ``RequestChain`` that can perform a unit of work that operates on an
/// `URLRequest` and ``HTTPResponse``.
///
/// The interceptor can perform pre-flight work on the `URLRequest` and post-flight work on the
/// ``HTTPResponse``, including the raw response `Data` stream of the response's ``HTTPResponse/chunks``.
///
/// ## Pre-Flight
/// After the ``RequestChain`` proceeds through the ``GraphQLInterceptor``s provided by it's ``InterceptorProvider``,
/// it will call ``GraphQLRequest/toURLRequest()`` on the final ``GraphQLRequest``. Each ``HTTPInterceptor`` provided by
/// the ``InterceptorProvider`` will then have it's ``intercept(request:next:)`` function called in sequential order
/// prior to fetching the request. When this function is called, the interceptor may
/// inspect or modify the provided `request`, which must then be passed into the `next` closure to continue through
/// the ``RequestChain``
///
/// ## Post-Flight
/// After the ``ApolloURLSession`` receives an initial response, an ``HTTPResponse`` will be returned by the call to
/// the `next` closure. As raw response data is received, the raw chunk `Data` is passed back up the interceptor chain
/// in reverse order such that the first ``HTTPInterceptor`` called will be the last to receive the response.
///
/// The response `Data` of the ``HTTPResponse/chunks`` may be inspected or modified by using the
/// ``HTTPResponse/mapChunks(_:)`` function of the ``HTTPResponse``. The interceptor must then return the mapped
/// ``HTTPResponse`` to continue through the ``RequestChain``.
public protocol HTTPInterceptor: Sendable {

  /// A closure called to proceed to the next step in the ``RequestChain`` after performing pre-flight work.
  ///
  /// - Parameters:
  ///   - Request: The `URLRequest` to send to the next step in the ``RequestChain``.
  ///
  /// - Returns: An ``HTTPResponse`` used to intercept raw response data chunks and perform post-flight work.
  typealias NextHTTPInterceptorFunction = @Sendable (URLRequest) async throws -> HTTPResponse

  /// The entry point used to intercept the ``URLRequest``.
  ///
  /// This function is called by the ``RequestChain`` during pre-flight operations. Post-flight work can be performed
  /// in the ``HTTPResponse/mapChunks(_:)`` function of the ``HTTPResponse`` returned by calling the `next` closure.
  ///
  /// - Parameters:
  ///   - request: The current pre-flight state of the request, may be modified by subsequent interceptors after
  ///   calling the `next` closure.
  ///   - next: The ``NextHTTPInterceptorFunction`` that should be called to proceed to the next step in the
  ///   ``RequestChain``.
  /// - Returns: The stream of response data to pass to the next interceptor for post-flight processing.
  func intercept(
    request: URLRequest,
    next: NextHTTPInterceptorFunction
  ) async throws -> HTTPResponse

}

/// A response from an HTTP request that is sent through a series of ``HTTPInterceptor``s in a ``RequestChain`` after
/// being fetched by an ``ApolloURLSession``.
public struct HTTPResponse: Sendable, ~Copyable {
  /// The HTTP response info received for the request
  public let response: HTTPURLResponse

  /// The stream of chunks received for the ``HTTPResponse/response`` as raw `Data`.
  ///
  /// Because some requests may have a multi-part response, such as subscriptions or operations using `@defer`, the
  /// response is processed as a stream of chunks. For requests that should have a single response chunk, the stream
  /// will emit a single value and then terminate.
  public let chunks: NonCopyableAsyncThrowingStream<Data>

  /// Maps the ``HTTPResponse/chunks`` of raw response data received for the response and returns a new ``HTTPResponse``
  /// with the ``HTTPResponse/chunks`` returned from the `transform` block
  ///
  /// - Parameter transform: A block called for each element emitted by the receiver's ``HTTPResponse/chunks`` stream.
  /// - Returns: An ``HTTPResponse`` with a ``HTTPResponse/chunks`` stream that emits the `Data` returned from the
  /// `transform` block.
  public consuming func mapChunks(
    _ transform: @escaping @Sendable (HTTPURLResponse, Data) async throws -> (Data)
  ) async -> HTTPResponse {
    let response = self.response
    let stream = await chunks.map { chunk in
      return try await transform(response, chunk)
    }
    return HTTPResponse(response: response, chunks: stream)
  }
}
