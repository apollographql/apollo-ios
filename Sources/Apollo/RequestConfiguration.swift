import Foundation

public struct RequestConfiguration: Sendable {
  public var requestTimeout: TimeInterval?
  public var writeResultsToCache: Bool

  public init(
    requestTimeout: TimeInterval? = nil,
    writeResultsToCache: Bool = true
  ) {
    self.requestTimeout = requestTimeout
    self.writeResultsToCache = writeResultsToCache
  }
}
