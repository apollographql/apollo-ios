import Foundation

public struct TestError: Error {
  let message: String?

  public init(_ message: String? = nil) {
    self.message = message
  }
}
