import Foundation

// MARK: - Emptiness + Optionality

public extension ApolloExtension where Base: Collection {
  
  /// Convenience helper to make `guard` statements more readable
  ///
  /// - returns: `true` if the collection has contents.
  var isNotEmpty: Bool {
    return !base.isEmpty
  }
}

extension Array: ApolloCompatible {}
extension Dictionary: ApolloCompatible {}

public extension ApolloExtension where Base: OptionalType, Base.WrappedType: Collection {
  
  /// - returns: `true` if the collection is empty or nil
  var isEmptyOrNil: Bool {
    switch base.underlying {
    case .none:
      return true
    case .some(let collection):
      return collection.isEmpty
    }
  }
  
  /// - returns: `true` if the collection is non-nil AND has contents.
  var isNotEmpty: Bool {
    switch base.underlying {
    case .none:
      return false
    case .some(let collection):
      return !collection.isEmpty
    }
  }
}

