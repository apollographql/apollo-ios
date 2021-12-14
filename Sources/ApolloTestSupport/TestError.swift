import Foundation

public struct TestError: Error, CustomDebugStringConvertible {
  let message: String?

  public init(_ message: String? = nil) {
    self.message = message
  }

  public var debugDescription: String {
    message ?? "TestError"
  }

}
