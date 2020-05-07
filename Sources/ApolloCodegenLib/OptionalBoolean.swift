import Foundation

extension Optional where Wrapped == Bool {
  /// It returns false if it is called on `nil`
  var boolValue: Bool {
    switch self {
    case .none:
      return false
    case .some(let actual):
      return actual
    }
  }
}
