/// A type erased wrapper for optional values.
///
/// This is used to help handle nested optional values in dyanmic JSON data.
@_spi(Internal)
public protocol AnyOptional {
  var optionalValue: Any? { get }
}

@_spi(Internal)
extension Optional: AnyOptional {
  @inlinable public var optionalValue: Any? {
    switch self {
      case .some(let value): return value
      case .none: return nil
    }
  }
}

extension AnyOptional {

  /// Unwraps a deeply nested optional recursively until it terminates with a `nil` or a value.
  /// 
  /// - Parameter as: The type to cast the unwrapped value as. If there is an unwrapped value,
  /// but it does not convert to this type, `nil` will still be returned.
  /// - Returns: The recursively unwrapped value.
  @_spi(Internal)
  @inlinable public func recursivelyUnwrapped<T>(as: T.Type = Any.self) -> T? {
    switch self.optionalValue {
    case .some(let value):
      guard let value = value as? (any AnyOptional) else {
        return value as? T
      }
      return value.recursivelyUnwrapped() as? T

    case .none: return nil
    }
  }

}
