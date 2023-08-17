import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A chain that allows a single network request to be created and executed.
final public class InterceptorRequestChain: Cancellable, RequestChain {

  public enum ChainError: Error, LocalizedError {
    case invalidIndex(chain: RequestChain, index: Int)
    case noInterceptors
    case unknownInterceptor(id: String)

    public var errorDescription: String? {
      switch self {
      case .noInterceptors:
        return "No interceptors were provided to this chain. This is a developer error."
      case .invalidIndex(_, let index):
        return "`proceedAsync` was called for index \(index), which is out of bounds of the receiver for this chain. Double-check the order of your interceptors."
      case let .unknownInterceptor(id):
        return "`proceedAsync` was called by unknown interceptor \(id)."
      }
    }
  }

  private let interceptors: [any ApolloInterceptor]
  private let callbackQueue: DispatchQueue

  private var interceptorIndexes: [String: Int] = [:]
  private var currentIndex: Int

  @Atomic public var isCancelled: Bool = false
  /// Something which allows additional error handling to occur when some kind of error has happened.
  public var additionalErrorHandler: ApolloErrorInterceptor?

  /// Creates a chain with the given interceptor array.
  ///
  /// - Parameters:
  ///   - interceptors: The array of interceptors to use.
  ///   - callbackQueue: The `DispatchQueue` to call back on when an error or result occurs.
  ///   Defaults to `.main`.
  public init(
    interceptors: [any ApolloInterceptor],
    callbackQueue: DispatchQueue = .main
  ) {
    self.interceptors = interceptors
    self.callbackQueue = callbackQueue
    self.currentIndex = 0

    for (index, interceptor) in interceptors.enumerated() {
      self.interceptorIndexes[interceptor.id] = index
    }
  }

  /// Kicks off the request from the beginning of the interceptor array.
  ///
  /// - Parameters:
  ///   - request: The request to send.
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - completion: The completion closure to call when the request has completed.
  public func kickoff<Operation: GraphQLOperation>(
    request: HTTPRequest<Operation>,
    context: RequestContext?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    assert(self.currentIndex == 0, "The interceptor index should be zero when calling this method")

    guard let firstInterceptor = self.interceptors.first else {
      handleErrorAsync(
        ChainError.noInterceptors,
        request: request,
        response: nil,
        context: context,
        completion: completion
      )
      return
    }

    firstInterceptor.interceptAsync(
      chain: self,
      request: request,
      response: nil,
      context: context,
      completion: completion
    )
  }

  /// Proceeds to the next interceptor in the array.
  ///
  /// - Parameters:
  ///   - request: The in-progress request object
  ///   - response: [optional] The in-progress response object, if received yet
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - completion: The completion closure to call when data has been processed and should be
  ///   returned to the UI.
  public func proceedAsync<Operation: GraphQLOperation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    context: RequestContext?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    let nextIndex = self.currentIndex + 1

    proceedAsync(
      interceptorIndex: nextIndex,
      request: request,
      response: response,
      context: context,
      completion: completion
    )
  }

  /// Proceeds to the next interceptor in the array.
  ///
  /// - Parameters:
  ///   - request: The in-progress request object
  ///   - response: [optional] The in-progress response object, if received yet
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - interceptor: The interceptor that has completed processing and is ready to pass control
  ///   on to the next interceptor in the chain.
  ///   - completion: The completion closure to call when data has been processed and should be
  ///   returned to the UI.
  public func proceedAsync<Operation: GraphQLOperation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    context: RequestContext?,
    interceptor: any ApolloInterceptor,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard let currentIndex = interceptorIndexes[interceptor.id] else {
      self.handleErrorAsync(
        ChainError.unknownInterceptor(id: interceptor.id),
        request: request,
        response: response,
        context: context,
        completion: completion
      )
      return
    }

    let nextIndex = currentIndex + 1

    proceedAsync(
      interceptorIndex: nextIndex,
      request: request,
      response: response,
      context: context,
      completion: completion
    )
  }

  private func proceedAsync<Operation: GraphQLOperation>(
    interceptorIndex: Int,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    context: RequestContext?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard !self.isCancelled else {
      // Do not proceed, this chain has been cancelled.
      return
    }

    if self.interceptors.indices.contains(interceptorIndex) {
      self.currentIndex = interceptorIndex
      let interceptor = self.interceptors[interceptorIndex]

      interceptor.interceptAsync(
        chain: self,
        request: request,
        response: response,
        context: context,
        completion: completion
      )

    } else {
      if let result = response?.parsedResponse {
        // We got to the end of the chain with a parsed response. Yay! Return it.
        self.returnValueAsync(
          for: request,
          value: result,
          context: context,
          completion: completion
        )

      } else {
        // We got to the end of the chain and no parsed response is there, there needs to be more processing.
        self.handleErrorAsync(
          ChainError.invalidIndex(chain: self, index: interceptorIndex),
          request: request,
          response: response,
          context: context,
          completion: completion
        )
      }
    }
  }

  /// Cancels the entire chain of interceptors.
  public func cancel() {
    guard !self.isCancelled else {
      // Do not proceed, this chain has been cancelled.
      return
    }

    self.$isCancelled.mutate { $0 = true }

    // If an interceptor adheres to `Cancellable`, it should have its in-flight work cancelled as well.
    for interceptor in self.interceptors {
      if let cancellableInterceptor = interceptor as? Cancellable {
        cancellableInterceptor.cancel()
      }
    }
  }

  /// Restarts the request starting from the first interceptor.
  ///
  /// - Parameters:
  ///   - request: The request to retry
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - completion: The completion closure to call when the request has completed.
  public func retry<Operation: GraphQLOperation>(
    request: HTTPRequest<Operation>,
    context: RequestContext?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard !self.isCancelled else {
      // Don't retry something that's been cancelled.
      return
    }

    self.currentIndex = 0
    self.kickoff(request: request, context: context, completion: completion)
  }

  /// Handles the error by returning it on the appropriate queue, or by applying an additional
  /// error interceptor if one has been provided.
  ///
  /// - Parameters:
  ///   - error: The error to handle
  ///   - request: The request, as far as it has been constructed.
  ///   - response: The response, as far as it has been constructed.
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - completion: The completion closure to call when work is complete.
  public func handleErrorAsync<Operation: GraphQLOperation>(
    _ error: Error,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    context: RequestContext?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard !self.isCancelled else {
      return
    }

    guard let additionalHandler = self.additionalErrorHandler else {
      self.callbackQueue.async {
        completion(.failure(error))
      }
      return
    }

    // Capture callback queue so it doesn't get reaped when `self` is dealloced
    let callbackQueue = self.callbackQueue
    additionalHandler.handleErrorAsync(
      error: error,
      chain: self,
      request: request,
      response: response,
      context: context
    ) { result in
      callbackQueue.async {
        completion(result)
      }
    }
  }

  /// Handles a resulting value by returning it on the appropriate queue.
  ///
  /// - Parameters:
  ///   - request: The request, as far as it has been constructed.
  ///   - value: The value to be returned
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - completion: The completion closure to call when work is complete.
  public func returnValueAsync<Operation: GraphQLOperation>(
    for request: HTTPRequest<Operation>,
    value: GraphQLResult<Operation.Data>,
    context: RequestContext?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard !self.isCancelled else {
      return
    }

    self.callbackQueue.async {
      completion(.success(value))
    }
  }
}
