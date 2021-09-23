import Foundation

@dynamicMemberLookup
public enum Nullable<Wrapped>: ExpressibleByNilLiteral {

  /// The absence of a value.
  /// Functionally equivalent to `nil`.
  case none

  /// The presence of an explicity null value.
  /// Functionally equivalent to `NSNull`
  case null

  /// The presence of a value, stored as `Wrapped`
  case some(Wrapped)

  public var unwrapped: Wrapped? {
    guard case let .some(wrapped) = self else { return nil }
    return wrapped
  }

  public var unsafelyUnwrapped: Wrapped {
    guard case let .some(wrapped) = self else { fatalError("Force unwrap Nullable value failed!") }
    return wrapped
  }

  public subscript<T>(dynamicMember path: KeyPath<Wrapped, T>) -> T? {
    unwrapped?[keyPath: path]
  }

  public init(nilLiteral: ()) {
    self = .none
  }  
}
