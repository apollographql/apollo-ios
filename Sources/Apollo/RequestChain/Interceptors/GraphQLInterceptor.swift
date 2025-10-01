import ApolloAPI
import Foundation

/// The stream of results passed through a series of ``GraphQLInterceptor``s by a ``RequestChain``.
///
/// This is a stream of ``ParsedResult``s wrapped in a ``NonCopyableAsyncThrowingStream`` to ensure the stream's values
/// are not consumed by intermediary interceptors.
///
/// Because some requests may have a multi-part response, such as subscriptions or operations using `@defer`, the
/// results of a ``RequestChain`` are processed as a stream. For requests that should have a single response, the stream
/// will emit a single value and then terminate.
public typealias InterceptorResultStream<Request: GraphQLRequest> =
  NonCopyableAsyncThrowingStream<ParsedResult<Request.Operation>>

/// A protocol for an interceptor in a ``RequestChain`` that can perform a unit of work that operates on a
/// ``GraphQLRequest`` and ``ParsedResult``.
///
/// The interceptor can perform pre-flight work on the ``GraphQLRequest`` and post-flight work on the ``ParsedResult``.
///
/// ## Pre-Flight
/// Each ``GraphQLInterceptor`` provided by an ``InterceptorProvider`` will have it's ``intercept(request:next:)``
/// function called in sequential order prior to fetching the request.
///
/// The interceptor may inspect or modify the provided `request`, which must then be passed into the `next` closure to
/// continue through the ``RequestChain``
///
/// ## Post-Flight
/// After response data is fetched and parsed, the ``ParsedResult`` will be emitted by the ``InterceptorResultStream``
/// returned by the call to the `next` closure. The ``ParsedResult`` is passed back up the interceptor chain in reverse
/// order such that the first interceptor called will be the last to receive the response.
///
/// The response may be inspected or modified by using the mapping functions of ``NonCopyableAsyncThrowingStream``.
/// The interceptor must then return the stream to continue through the ``RequestChain``.
///
/// ## Error Handling
/// Both pre-flight and post-flight errors can be caught using the ``NonCopyableAsyncThrowingStream/mapErrors(_:)``
/// function of the ``InterceptorResultStream`` returned by calling the `next` closure. This will catch any errors
/// thrown in later steps of the ``RequestChain``, including:
/// - Pre-flight errors thrown by ``GraphQLInterceptor``s later in the ``RequestChain``.
/// - Networking errors thrown by the ``ApolloURLSession`` or ``HTTPInterceptor``s in the ``RequestChain``.
/// - Parsing errors thrown by the ``ResponseParsingInterceptor`` of the ``RequestChain``.
/// - Post-flight errors thrown by ``GraphQLInterceptor``s later in the request chain.
///
/// Your ``NonCopyableAsyncThrowingStream/mapErrors(_:)`` closure may rethrow the same error or a different error,
/// which will then be passed up through the rest of the request chain. If possible, you may recover from the error
/// by constructing and returning a ``ParsedResult``. Returning `nil` will suppress the error and terminate the
/// ``RequestChain``'s stream without emitting a result.
/// 
/// It is not required that every interceptor implement error handling. A ``GraphQLInterceptor`` that does not call
/// ``NonCopyableAsyncThrowingStream/mapErrors(_:)`` will be skipped if an error is emitted.
/// 
/// ## Example
/// As an example, a simple logging interceptor might look like this:
/// ```swift
/// struct LoggingInterceptor: GraphQLInterceptor {
/// 
/// let logger: Logger
/// 
/// func intercept<Request: GraphQLRequest>(
///   request: Request,
///   next: NextInterceptorFunction<Request>
/// ) async throws -> InterceptorResultStream<Request> {
///   // Pre-flight work
///   logger.log(request: request)
/// 
///   // Proceed to next interceptor
///   return await next(request)
///   .map { response in
///     // Post-flight work
///     logger.log(response: response)
///     return response
/// 
///   }.mapErrors { error in
///     // Handle errors from later steps of the `RequestChain`
///     logger.log(error: error)
/// 
///     // Rethrows the error to the next interceptor.
///     throw error
///   }
/// }
/// ```
public protocol GraphQLInterceptor: Sendable {

  /// A closure called to proceed to the next step in the ``RequestChain`` after performing pre-flight work.
  ///
  /// - Parameters:
  ///   - Request: The ``GraphQLRequest`` to send to the next step in the ``RequestChain``.
  ///
  /// - Returns: An ``InterceptorResultStream`` used to intercept response data and perform post-flight work.
  typealias NextInterceptorFunction<Request: GraphQLRequest> = @Sendable (Request) async ->
    InterceptorResultStream<Request>

  /// The entry point used to intercept the ``GraphQLRequest``.
  ///
  /// This function is called by the ``RequestChain`` during pre-flight operations. Post-flight work can be performed
  /// in the `map` functions of the ``InterceptorResultStream`` returned by calling the `next` closure.
  ///
  /// - Parameters:
  ///   - request: The current pre-flight state of the request, may be modified by subsequent interceptors after
  ///   calling the `next` closure.
  ///   - next: The ``NextInterceptorFunction`` that should be called to proceed to the next step in the ``RequestChain``.
  /// - Returns: The stream of results to pass to the next interceptor for post-flight processing.
  func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<Request>

}
