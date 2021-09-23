import Foundation

/// Indicates the presence of a value, supporting both `nil` and `null` values.
///
/// In GraphQL, explicitly providing a `null` value for an input value to a field argument is
/// semantically different from not providing a value at all (`nil`). This enum allows you to
/// distinguish your input values between `null` and `nil`.
///
/// - See: [GraphQLSpec - Input Values - Null Value](http://spec.graphql.org/June2018/#sec-Null-Value)
@dynamicMemberLookup
public enum GraphQLNullable<Wrapped>: ExpressibleByNilLiteral {

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
