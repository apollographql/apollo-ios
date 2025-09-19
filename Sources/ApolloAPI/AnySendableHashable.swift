import Foundation

/// This caseless enum provides static helper functions for use when implementing
/// `Equatable` and `Hashable` conformance on types that use `any Sendable & Hashable`.
///
/// - warning: These functions are not intended for public consumption and should only be used
/// internally by Apollo libraries.
@_spi(Internal)
public enum AnySendableHashable {

  @inlinable
  public static func equatableCheck<T: Sendable & Hashable>(
    _ lhs: T,
    _ rhs: any Sendable & Hashable
  ) -> Bool {
    lhs == rhs as? T
  }

  @inlinable
  public static func equatableCheck<T: Hashable & Sendable>(
    _ lhs: [T: any Sendable & Hashable],
    _ rhs: [T: any Sendable & Hashable]
  ) -> Bool {
    guard lhs.keys == rhs.keys else { return false }

    return lhs.allSatisfy {
      guard let rhsValue = rhs[$0.key],
            equatableCheck($0.value, rhsValue) else {
        return false
      }
      return true
    }
  }

  @inlinable
  public static func equatableCheck<T: Hashable & Sendable>(
    _ lhs: [T: any Sendable & Hashable]?,
    _ rhs: [T: any Sendable & Hashable]?
  ) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.some, .none), (.none, .some): return false
    case let (.some(lhsValue), .some(rhsValue)):
      return equatableCheck(lhsValue, rhsValue)
    }
  }

  @inlinable
  public static func equatableCheck(
    _ lhs: (any Sendable & Hashable)?,
    _ rhs: (any Sendable & Hashable)?
  ) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.some, .none), (.none, .some): return false
    case let (.some(lhsValue), .some(rhsValue)):
      return equatableCheck(lhsValue, rhsValue)
    }
  }
}

@_spi(Internal)
extension Hasher {

  @inlinable
  public mutating func combine(_ optionalJSONValue: (any Sendable & Hashable)?) {
    if let value = optionalJSONValue {
      self.combine(1 as UInt8)
      self.combine(value)
    } else {
      // This mimics the implementation of combining a nil optional from the Swift language core
      // Source reference at:
      // https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Optional.swift#L590
      self.combine(0 as UInt8)
    }
  }

  @inlinable
  public mutating func combine<T: Sendable & Hashable>(
    _ dictionary: [T: any Sendable & Hashable]
  ) {
    // From Dictionary's Hashable implementation
    var commutativeHash = 0
    for (key, value) in dictionary {
      var elementHasher = self
      elementHasher.combine(key)
      elementHasher.combine(AnyHashable(value))
      commutativeHash ^= elementHasher.finalize()
    }
    self.combine(commutativeHash)
  }

  @inlinable
  public mutating func combine<T: Sendable & Hashable>(
    _ dictionary: [T: any Sendable & Hashable]?
  ) {
    if let value = dictionary {
      self.combine(value)
    } else {
      self.combine(Optional<[T: any Sendable & Hashable]>.none)
    }
  }
}
