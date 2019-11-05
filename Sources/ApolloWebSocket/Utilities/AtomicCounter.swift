import Foundation

class AtomicCounter {
  private let lock = NSLock()
  private var _value = 0
  
  func next() -> Int {
    lock.lock()
    _value += 1
    defer { lock.unlock() }
    
    return _value
  }
}
