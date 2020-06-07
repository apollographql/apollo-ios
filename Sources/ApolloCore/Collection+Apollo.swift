import Foundation

// MARK: - Emptiness + Optionality

public extension Collection {

  /// Convenience helper to make `guard` statements more readable
  ///
  /// - returns: `true` if the collection has contents.
  var apollo_isNotEmpty: Bool {
    return !self.isEmpty
  }
}

public extension Optional where Wrapped: Collection {

  /// - returns: `true` if the collection is empty or nil
  var apollo_isEmptyOrNil: Bool {
    switch self {
    case .none:
      return true
    case .some(let collection):
      return collection.isEmpty
    }
  }
  
  /// - returns: `true` if the collection is non-nil AND has contents.
  var apollo_isNotEmpty: Bool {
    switch self {
    case .none:
      return false
    case .some(let collection):
      return collection.apollo_isNotEmpty
    }
  }
}
