class SessionDelegate: NSObject {
  
  private var tasks: [Int: (Progress) -> Void] = [:]
  private let lock = NSLock()
  
  func add(task: URLSessionTask, progressHandler: @escaping (Progress) -> Void) {
    lock.lock()
    defer { lock.unlock() }
    
    self.tasks[task.taskIdentifier] = progressHandler
  }
  
  func get(task: URLSessionTask) -> ((Progress) -> Void)? {
    lock.lock()
    defer { lock.unlock() }
    
    return self.tasks[task.taskIdentifier]
  }
  
  func remove(task: URLSessionTask) {
    lock.lock()
    defer { lock.unlock() }
    
    self.tasks.removeValue(forKey: task.taskIdentifier)
  }
}

extension SessionDelegate: URLSessionTaskDelegate {
  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    if let progressHandler = self.get(task: task) {
      progressHandler(Progress((totalBytesSent/totalBytesExpectedToSend)) * 100)
    }
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    self.remove(task: task)
  }
}
