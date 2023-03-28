import Foundation

public extension String {
  func crlfFormattedData() -> Data {
    return replacingOccurrences(of: "\n\n", with: "\r\n\r\n").data(using: .utf8)!
  }
}
