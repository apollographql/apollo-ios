import Foundation

final class Mutex {
  private var _lockPtr = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)

  init() {
    let result = pthread_mutex_init(_lockPtr, nil)
    assert(result == 0)
  }

  deinit {
    let result = pthread_mutex_destroy(_lockPtr)
    _lockPtr.deinitialize(count: 1)
    _lockPtr.deallocate()
    assert(result == 0)
  }

  func lock() {
    let result = pthread_mutex_lock(_lockPtr)
    assert(result == 0)
  }

  func unlock() {
    let result = pthread_mutex_unlock(_lockPtr)
    assert(result == 0)
  }

  func withLock<T>(_ body: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try body()
  }
}

final class ReadWriteLock {
  private var _lockPtr = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)

  init() {
    let status = pthread_rwlock_init(_lockPtr, nil)
    assert(status == 0)
  }

  deinit {
    let status = pthread_rwlock_destroy(_lockPtr)
    _lockPtr.deinitialize(count: 1)
    _lockPtr.deallocate()
    assert(status == 0)
  }

  func lockForReading() {
    pthread_rwlock_rdlock(_lockPtr)
  }

  func lockForWriting() {
    pthread_rwlock_wrlock(_lockPtr)
  }

  func unlock() {
    pthread_rwlock_unlock(_lockPtr)
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
