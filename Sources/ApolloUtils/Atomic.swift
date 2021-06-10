import Foundation

/// Wrapper for a value protected by an NSLock
public class Atomic<T> {
  private let lock = NSLock()
  private var _value: T

  /// Designated initializer
  ///
  /// - Parameter value: The value to begin with.
  public init(_ value: T) {
    _value = value
  }

  /// The current value. Read-only. To update the underlying value, use `mutate`.
  public var value: T {
    lock.lock()
    defer { lock.unlock() }
    
    return _value
  }
  
  /// Mutates the underlying value within a lock.
  /// - Parameter block: The block to execute to mutate the value.
  /// - Returns: The value returned by the block.
  public func mutate<U>(block: (inout T) -> U) -> U {
    lock.lock()
    let result = block(&_value)
    lock.unlock()
    return result
  }
}

public extension Atomic where T == Int {

  /// Increments in a lock-compatible fashion
  func increment() -> T {
    lock.lock()
    defer { lock.unlock() }

    _value += 1
    return _value
  }
}
