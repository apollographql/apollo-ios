class SessionDelegate: NSObject {
  class SessionDelegateTask {
    let completionHandler: (Data?, URLResponse?, Error?) -> Void
    let progressHandler: ((Progress) -> Void)?
    var data = Data()
    
    init(completionHandler: @escaping  (Data?, URLResponse?, Error?) -> Void, progressHandler: ((Progress) -> Void)? = nil) {
      self.completionHandler = completionHandler
      self.progressHandler = progressHandler
    }
    
    func didReceiveData(data: Data) {
      self.data.append(data)
    }
  }
  
  private var tasks: [Int: SessionDelegateTask] = [:]
  private let lock = Mutex()
  
  func add(task: URLSessionTask, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, progressHandler: ((Progress) -> Void)? = nil) {
    self.lock.lock()
    defer { self.lock.unlock() }
    
    self.tasks[task.taskIdentifier] = SessionDelegateTask(completionHandler: completionHandler, progressHandler: progressHandler)
  }
  
  fileprivate func get(task: URLSessionTask) -> SessionDelegateTask? {
    return lock.withLock {
      return self.tasks[task.taskIdentifier]
    }
  }
  
  fileprivate func remove(task: URLSessionTask) {
    self.lock.lock()
    defer { self.lock.unlock() }
    
    self.tasks.removeValue(forKey: task.taskIdentifier)
  }
}

extension SessionDelegate: URLSessionDataDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
    completionHandler(URLSession.ResponseDisposition.allow)
  }
}

extension SessionDelegate: URLSessionTaskDelegate {
  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    if let sessionTask = self.get(task: task), let progressHandler = sessionTask.progressHandler {
      let progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
      progressHandler(Progress(progress * 100))
    }
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    if let sessionTask = self.get(task: dataTask) {
      sessionTask.didReceiveData(data: data)
    }
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let sessionTask = self.get(task: task) {
      self.remove(task: task)
      
      sessionTask.completionHandler(sessionTask.data, task.response, error)
    }
  }
}
