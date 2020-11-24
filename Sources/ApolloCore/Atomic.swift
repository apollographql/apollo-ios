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
  public func mutate(block: (inout T) -> Void) {
    lock.lock()
    block(&_value)
    lock.unlock()
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
