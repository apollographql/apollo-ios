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

  /// The current value.
  public var value: T {
    get {
      lock.lock()
      defer { lock.unlock() }

      return _value
    }
    set {
      lock.lock()
      defer { lock.unlock() }

      _value = newValue
    }
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
