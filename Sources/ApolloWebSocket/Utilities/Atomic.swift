import Foundation

class Atomic<T> {
  private let lock = NSLock()
  private var _value: T
  
  init(_ value: T) {
    _value = value
  }
  
  var value: T {
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

extension Atomic where T == Int {
  
  func increment() -> T {
    lock.lock()
    defer { lock.unlock() }
    
    _value += 1
    return _value
  }
}
