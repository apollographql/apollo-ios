import Foundation

extension Optional where Wrapped == Bool {
  var valueOrFalseIfNone: Bool {
    switch self {
    case .none:
      return false
    case .some(let actual):
      return actual
    }
  }
}
