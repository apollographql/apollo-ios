import Foundation

/// A type erased wrapper for optional values.
///
/// This is used to help handle nested optional values in dyanmic JSON data.
@_spi(Internal)
public protocol AnyOptional {}

@_spi(Internal)
extension Optional: AnyOptional { }

extension Optional where Wrapped: Sendable {

  /// Converts the optional to a `GraphQLNullable.
  ///
  /// - Double nested optional (ie. `Optional.some(nil)`) -> `GraphQLNullable.null`.
  /// - `Optional.none` -> `GraphQLNullable.none`
  /// - `Optional.some` -> `GraphQLNullable.some`
  @_spi(Internal)
  public var asNullable: GraphQLNullable<Wrapped> {
    unwrapAsNullable()
  }

  private func unwrapAsNullable(nullIfNil: Bool = false) -> GraphQLNullable<Wrapped> {
    switch self {
    case .none: return nullIfNil ? .null : .none

    case .some(let value as any AnyOptional):
      return (value as! Self).unwrapAsNullable(nullIfNil: true)

    case .some(is NSNull):
      return .null

    case .some(let value):
      return .some(value)
    }
  }
}
