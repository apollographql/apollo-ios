import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

public typealias InterceptorResultStream<Request: GraphQLRequest> =
NonCopyableAsyncThrowingStream<ParsedResult<Request.Operation>>

public struct ParsedResult<Operation: GraphQLOperation>: Sendable, Hashable {
  public let result: GraphQLResponse<Operation>
  public let cacheRecords: RecordSet?

  public init(result: GraphQLResponse<Operation>, cacheRecords: RecordSet?) {
    self.result = result
    self.cacheRecords = cacheRecords
  }
}

/// A protocol to set up a chainable unit of networking work that operates on a `GraphQLRequest` and `GraphQLResponse`.
///
/// Each ``GraphQLInterceptor`` provided by an ``InterceptorProvider`` will have it's intercept function called in
/// sequential order prior to beginning execution of the request. After request execution is complete, the
/// ``ParsedResult`` (which includes the ``GraphQLResponse``) is passed back up the interceptor chain in reverse order
/// such that the first interceptor called will be the last to receive the response.
///
/// ## Pre-Flight
/// When the `intercept(request:next:)` function is called, the interceptor may inspect or modify the provided request.
/// The request must then be passed into the `next` closure to continue through the ``RequestChain``
///
/// ## Post-Flight
/// After the request has been executed, the response will be emitted by the `InterceptorResultStream` returned by
/// the call to the `next` closure. The response may be inspected or modified by using the stream's, `.map` and
/// `.mapErrors` functions.
/// The interceptor must then return the stream to continue through the ``RequestChain``
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
///   logger.log(request: request)
///
///   return await next(request).map { response in
///     logger.log(response: response)
///     return response
///   }.mapErrors { error in
///     logger.log(error: error)
///     throw error
///   }
/// }
/// ```
/// Additionally, the interceptor could modify the `request` passed into the `next(request)` closure; the `response`
/// returned from the `.map` closure, or the error thrown from the `mapErrors` closure.
public protocol GraphQLInterceptor: Sendable {

  typealias NextInterceptorFunction<Request: GraphQLRequest> = @Sendable (Request) async ->
    InterceptorResultStream<Request>

  /// Called when this interceptor should do its work.
  ///
  /// - Parameters:
  ///   - chain: The chain the interceptor is a part of.
  ///   - request: The request, as far as it has been constructed
  ///   - response: [optional] The response, if received
  ///   - completion: The completion block to fire when data needs to be returned to the UI.
  func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<Request>

}
