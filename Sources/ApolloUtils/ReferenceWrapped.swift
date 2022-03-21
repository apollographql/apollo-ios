import Foundation

/// Used to wrap a value type to prevent copy on argument passing.
public class ReferenceWrapped<T> {
  /// Used to access the underlying wrapped value type.
  public let value: T

  /// Designated Initializer
  ///
  /// - Parameter value: The value type that will be wrapped and available through the `value` property.
  public init (value: T) {
    self.value = value
  }
}
