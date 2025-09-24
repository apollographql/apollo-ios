import Foundation

// MARK: Status extensions
extension HTTPURLResponse {
  var isSuccessful: Bool {
    return (200..<300).contains(statusCode)
  }
}
