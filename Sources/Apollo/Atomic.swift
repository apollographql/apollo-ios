import Foundation

/// Wrapper for a value protected by an `NSLock`
@propertyWrapper
public final class Atomic<T> {
  private let lock = NSLock()
  private var _value: T

  /// Designated initializer
  ///
  /// - Parameter value: The value to begin with.
  public init(wrappedValue: T) {
    _value = wrappedValue
  }

  /// The current value. Read-only. To update the underlying value, use ``mutate(block:)``.
  ///
  /// Allowing the ``wrappedValue`` to be set using a setter can cause concurrency issues when
  /// mutating the value of a wrapped value type such as an `Array`. This is due to the copying of
  /// value types as described in [this article](https://www.donnywals.com/why-your-atomic-property-wrapper-doesnt-work-for-collection-types/).
  public var wrappedValue: T {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _value
    }    
  }

  public var projectedValue: Atomic { self }
  
  /// Mutates the underlying value within a lock.
  ///
  /// - Parameter block: The block executed to mutate the value.
  /// - Returns: The value returned by the block.
  @discardableResult
  public func mutate<U>(block: (inout T) -> U) -> U {
    lock.lock()
    defer { lock.unlock() }
    return block(&_value)
  }
}

extension Atomic: @unchecked Sendable where T: Sendable {}

public extension Atomic where T : Numeric {

  /// Increments the wrapped `Int` atomically, adding +1 to the value.
  @discardableResult
  func increment() -> T {
    lock.lock()
    defer { lock.unlock() }

    _value += 1
    return _value
  }

  /// Decrements the wrapped `Int` atomically, subtracting 1 from the value.
  @discardableResult
  func decrement() -> T {
    lock.lock()
    defer { lock.unlock() }

    _value -= 1
    return _value
  }
}
