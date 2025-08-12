import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor to enforce a maximum number of retries of any `HTTPRequest` with optional exponential backoff support
public class MaxRetryInterceptor: ApolloInterceptor {
  
  /// A configuration object that defines behavior for retry logic and exponential backoff.
  public struct Configuration {
    /// Maximum number of retries allowed. Defaults to `3`.
    public let maxRetries: Int
    /// Initial delay in seconds for exponential backoff. Defaults to `0.3`.
    public let baseDelay: TimeInterval
    /// Multiplier for exponential backoff calculation. Defaults to `2.0`.
    public let multiplier: Double
    /// Maximum delay cap in seconds to prevent excessive wait times. Defaults to `20.0`.
    public let maxDelay: TimeInterval
    /// Whether to enable exponential backoff delays between retries. Defaults to `false`.
    public let enableExponentialBackoff: Bool
    /// Whether to add jitter to delays to prevent thundering herd problems. Defaults to `true`.
    public let enableJitter: Bool
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - maxRetries: Maximum number of retries allowed.
    ///   - baseDelay: Initial delay in seconds for exponential backoff.
    ///   - multiplier: Multiplier for exponential backoff calculation. Should be ≥ 1.0.
    ///   - maxDelay: Maximum delay cap in seconds to prevent excessive wait times.
    ///   - enableExponentialBackoff: Whether to enable exponential backoff delays between retries.
    ///   - enableJitter: Whether to add jitter to delays to prevent thundering herd problems.
    public init(
      maxRetries: Int = 3,
      baseDelay: TimeInterval = 0.3,
      multiplier: Double = 2.0,
      maxDelay: TimeInterval = 20.0,
      enableExponentialBackoff: Bool = false,
      enableJitter: Bool = true
    ) {
      self.maxRetries = maxRetries
      self.baseDelay = baseDelay
      self.multiplier = multiplier
      self.maxDelay = maxDelay
      self.enableExponentialBackoff = enableExponentialBackoff
      self.enableJitter = enableJitter
    }
  }
  
  private let configuration: Configuration
  private var hitCount = 0

  public var id: String = UUID().uuidString
  
  public enum RetryError: Error, LocalizedError {
    case hitMaxRetryCount(count: Int, operationName: String)
    
    public var errorDescription: String? {
      switch self {
      case .hitMaxRetryCount(let count, let operationName):
        return "The maximum number of retries (\(count)) was hit without success for operation \"\(operationName)\"."
      }
    }
  }
  
  /// Designated initializer.
  ///
  /// - Parameter maxRetriesAllowed: How many times a query can be retried, in addition to the initial attempt before
  public init(maxRetriesAllowed: Int = 3) {
    self.configuration = Configuration(maxRetries: maxRetriesAllowed)
  }
  
  /// Designated initializer with full configuration support.
  ///
  /// - Parameter configuration: Configuration object defining retry behavior and exponential backoff settings.
  public init(configuration: Configuration) {
    self.configuration = configuration
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) {
    guard self.hitCount <= self.configuration.maxRetries else {
      let error = RetryError.hitMaxRetryCount(
        count: self.configuration.maxRetries,
        operationName: Operation.operationName
      )

      chain.handleErrorAsync(
        error,
        request: request,
        response: response,
        completion: completion
      )
      
      return
    }
    
    self.hitCount += 1
    
    // Apply exponential backoff delay if enabled and this is a retry (hitCount > 1)
    if self.configuration.enableExponentialBackoff && self.hitCount > 1 {
      let delay = calculateExponentialBackoffDelay()
      DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) { [weak self] in
        guard let self = self else { return }
        chain.proceedAsync(
          request: request,
          response: response,
          interceptor: self,
          completion: completion
        )
      }
    } else {
      chain.proceedAsync(
        request: request,
        response: response,
        interceptor: self,
        completion: completion
      )
    }
  }
  
  /// Calculates the exponential backoff delay based on current retry attempt.
  ///
  /// - Returns: The calculated delay in seconds, including jitter if enabled.
  private func calculateExponentialBackoffDelay() -> TimeInterval {
    // Calculate exponential delay: baseDelay * multiplier^(hitCount - 1)
    // We use (hitCount - 1) because hitCount includes the initial attempt
    let retryAttempt = hitCount - 1
    let exponentialDelay = configuration.baseDelay * pow(configuration.multiplier, Double(retryAttempt))
    
    // Apply maximum delay cap
    let cappedDelay = min(exponentialDelay, configuration.maxDelay)
    
    // Apply jitter if enabled to prevent thundering herd problems
    if configuration.enableJitter {
      // Equal jitter: random value between 50% and 100% of calculated delay
      let minDelay = cappedDelay / 2
      return TimeInterval.random(in: minDelay...cappedDelay)
    } else {
      return cappedDelay
    }
  }
}
