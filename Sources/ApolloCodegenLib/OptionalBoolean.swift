import Foundation

extension Optional where Wrapped == Bool {
  
  /// The value of the unwrapped `Bool`, or false if optional value is `.none`
  var apollo_boolValue: Bool {
    switch self {
    case .none:
      return false
    case .some(let actual):
      return actual
    }
  }
}
