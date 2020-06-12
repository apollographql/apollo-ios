import Foundation

extension Optional: ApolloCompatible {}

public extension ApolloExtension where Base == Optional<Bool> {
  
  /// The value of the unwrapped `Bool`, or false if optional value is `.none`
  var boolValue: Bool {
    switch base {
    case .none:
      return false
    case .some(let actual):
      return actual
    }
  }
}

