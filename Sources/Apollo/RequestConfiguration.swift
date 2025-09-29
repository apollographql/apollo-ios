import Foundation

/// ``RequestConfiguration`` allows you to customize various aspects of individual requests. All ``ApolloClient``
/// request methods (`fetch`, `perform`, `upload`, `subscribe`) accept an optional `requestConfiguration` parameter.
public struct RequestConfiguration: Sendable {

  /// The timeout interval for network requests. If not specified, the default timeout from the underlying
  /// `URLSession` is used.
  public var requestTimeout: TimeInterval?

  /// Whether to write operation results to the cache. Defaults to `true`.
  public var writeResultsToCache: Bool

  /// Designated Initializer
  /// - Parameters:
  ///   - requestTimeout: (optional) The timeout interval for network requests. If not specified, the default timeout from the underlying `URLSession` is used.
  ///   - writeResultsToCache: Whether to write operation results to the cache. Defaults to `true`.
  public init(
    requestTimeout: TimeInterval? = nil,
    writeResultsToCache: Bool = true
  ) {
    self.requestTimeout = requestTimeout
    self.writeResultsToCache = writeResultsToCache
  }
}
