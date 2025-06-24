public struct FetchBehavior: Sendable, Hashable {

  public var shouldAttemptCacheRead: Bool

  public var shouldAttemptCacheWrite: Bool

  public var shouldAttemptNetworkFetch: NetworkBehavior

  public init(
    shouldAttemptCacheRead: Bool,
    shouldAttemptCacheWrite: Bool,
    shouldAttemptNetworkFetch: NetworkBehavior
  ) {
    self.shouldAttemptCacheRead = shouldAttemptCacheRead
    self.shouldAttemptCacheWrite = shouldAttemptCacheWrite
    self.shouldAttemptNetworkFetch = shouldAttemptNetworkFetch
  }

  public enum NetworkBehavior: Sendable {
    case never
    case always
    case onCacheFailure
  }

  public func shouldFetchFromNetwork(hadSuccessfulCacheRead: Bool) -> Bool {
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
