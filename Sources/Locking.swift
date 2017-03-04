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
  
  func lock<T>(_ body: () throws -> T) rethrows -> T {
    pthread_mutex_lock(mutex)
    defer { pthread_mutex_unlock(mutex) }
    return try body()
  }
}
