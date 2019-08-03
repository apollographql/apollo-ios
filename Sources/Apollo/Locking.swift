import Foundation

final class Mutex {
  private var _lock = pthread_mutex_t()
  
  init() {
    let result = pthread_mutex_init(&_lock, nil)
    assert(result == 0)
  }
  
  deinit {
    let result = pthread_mutex_destroy(&_lock)
    assert(result == 0)
  }
  
  func lock() {
    let result = pthread_mutex_lock(&_lock)
    assert(result == 0)
  }
  
  func unlock() {
    let result = pthread_mutex_unlock(&_lock)
    assert(result == 0)
  }
  
  func withLock<T>(_ body: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try body()
  }
}

final class ReadWriteLock {
  private var _lock = pthread_rwlock_t()
  
  init() {
    let status = pthread_rwlock_init(&_lock, nil)
    assert(status == 0)
  }
  
  deinit {
    let status = pthread_rwlock_destroy(&_lock)
    assert(status == 0)
  }
  
  func lockForReading() {
    pthread_rwlock_rdlock(&_lock)
  }
  
  func lockForWriting() {
    pthread_rwlock_wrlock(&_lock)
  }
  
  func unlock() {
    pthread_rwlock_unlock(&_lock)
  }
  
  func withReadLock<T>(_ body: () throws -> T) rethrows -> T {
    lockForReading()
    defer { unlock() }
    return try body()
  }
  
  func withWriteLock<T>(_ body: () throws -> T) rethrows -> T {
    lockForWriting()
    defer { unlock() }
    return try body()
  }
}
