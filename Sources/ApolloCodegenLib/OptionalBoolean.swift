import Foundation

extension Optional where Wrapped == Bool {
  
  var apollo_boolValue: Bool {
    switch self {
    case .none:
      return false
    case .some(let actual):
      return actual
    }
  }
}
