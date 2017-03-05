final class Locking {
  let mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
  
  init() {
    pthread_mutex_init(mutex, nil)
  }
  
  deinit {
    pthread_mutex_destroy(mutex)
    mutex.deinitialize()
    mutex.deallocate(capacity: 1)
  }
  
  func lock() {
    pthread_mutex_lock(mutex)
  }
  
  func unlock() {
    pthread_mutex_unlock(mutex)
  }
  
  func lock<T>(_ body: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try body()
  }
}
