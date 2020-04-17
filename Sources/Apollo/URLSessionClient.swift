import Foundation

open class URLSessionClient: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
  
  public enum URLSessionClientError: Error {
    case noHTTPResponse(url: URL?)
    case sessionBecameInvalidWithoutUnderlyingError
    case dataForTaskNotFound(taskIdentifier: Int)
  }
  
  public typealias RawCompletion = (Data?, URLResponse?, Error?) -> Void
  public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
  
  private var completionBlocks = [Int: Completion]()
  private var rawCompletions = [Int: RawCompletion]()
  private var datas = [Int: Data]()
  private var responses = [Int: HTTPURLResponse]()
  
  open private(set) var session: URLSession!
  
  public init(sessionConfiguration: URLSessionConfiguration = .default,
              callbackQueue: OperationQueue? = .main) {
    super.init()
    self.session = URLSession(configuration: sessionConfiguration,
                              delegate: self,
                              delegateQueue: callbackQueue)
  }
  
  open func clearTask(with identifier: Int) {
    self.rawCompletions.removeValue(forKey: identifier)
    self.completionBlocks.removeValue(forKey: identifier)
    self.datas.removeValue(forKey: identifier)
    self.responses.removeValue(forKey: identifier)
  }
  
  open func clearAllTasks() {
    self.rawCompletions.removeAll()
    self.completionBlocks.removeAll()
    self.datas.removeAll()
    self.responses.removeAll()
  }
  
  @discardableResult
  open func sendRequest(_ request: URLRequest,
                        rawTaskCompletionHandler: @escaping RawCompletion,
                        completion: @escaping Completion) -> URLSessionTask {
    let dataTask = self.session.dataTask(with: request)
    self.rawCompletions[dataTask.taskIdentifier] = rawTaskCompletionHandler
    self.completionBlocks[dataTask.taskIdentifier] = completion
    self.datas[dataTask.taskIdentifier] = Data()
    dataTask.resume()
    
    return dataTask
  }
  
  open func cancel(task: URLSessionTask) {
    let taskID = task.taskIdentifier
    self.clearTask(with: taskID)
    task.cancel()
  }
  
  // MARK: - URLSessionDelegate
  
  open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    let finalError = error ?? URLSessionClientError.sessionBecameInvalidWithoutUnderlyingError
    for block in completionBlocks.values {
      block(.failure(finalError))
    }
    
    self.clearAllTasks()
  }
  
  @available(OSX 10.12, iOS 10.0, *)
  open func urlSession(_ session: URLSession,
                       task: URLSessionTask,
                       didFinishCollecting metrics: URLSessionTaskMetrics) {
    // No default implementation
  }
  
  open func urlSession(_ session: URLSession,
                       didReceive challenge: URLAuthenticationChallenge,
                       completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    completionHandler(.performDefaultHandling, nil)
  }
  
  
  #if os(iOS) || os(tvOS) || os(watchOS)
  open func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    // No default implementation
  }
  #endif
  
  // MARK: - NSURLSessionTaskDelegate
  
  open func urlSession(_ session: URLSession,
                       task: URLSessionTask,
                       didReceive challenge: URLAuthenticationChallenge,
                       completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    completionHandler(.performDefaultHandling, nil)
  }
  
  open func urlSession(_ session: URLSession,
                       taskIsWaitingForConnectivity task: URLSessionTask) {
    // No default implementation
  }
  
  open func urlSession(_ session: URLSession,
                       task: URLSessionTask,
                       didCompleteWithError error: Error?) {
    let taskIdentifier = task.taskIdentifier
    defer {
      self.clearTask(with: taskIdentifier)
    }
    
    
    guard
      let rawCompletion = self.rawCompletions.removeValue(forKey: taskIdentifier),
      let completion = self.completionBlocks.removeValue(forKey: taskIdentifier) else {
      // No completion blocks, the task has likely been cancelled. Bail out.
      return
    }
    
    let data = self.datas[taskIdentifier]
    let response = self.responses[taskIdentifier]
    
    rawCompletion(data, response, error)
    
    if let finalError = error {
      completion(.failure(finalError))
    } else {
      guard let finalData = data else {
        // Data is immediately created for a task on creation, so if it's not there, something's gone wrong.
        completion(.failure(URLSessionClientError.dataForTaskNotFound(taskIdentifier: taskIdentifier)))
        return
      }
      
      guard let finalResponse = response else {
        completion(.failure(URLSessionClientError.noHTTPResponse(url: task.currentRequest?.url)))
        return
      }
      
      completion(.success((finalData, finalResponse)))
    }
  }
  
  open func urlSession(_ session: URLSession,
                       task: URLSessionTask,
                       needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
    completionHandler(nil)
  }
  
  open func urlSession(_ session: URLSession,
                       task: URLSessionTask,
                       didSendBodyData bytesSent: Int64,
                       totalBytesSent: Int64,
                       totalBytesExpectedToSend: Int64) {
    // No default implementation
  }
  
  @available(iOS 11.0, OSXApplicationExtension 10.13, *)
  public func urlSession(_ session: URLSession,
                         task: URLSessionTask,
                         willBeginDelayedRequest request: URLRequest,
                         completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
    completionHandler(.continueLoading, request)
  }
  
  public func urlSession(_ session: URLSession,
                         task: URLSessionTask,
                         willPerformHTTPRedirection response: HTTPURLResponse,
                         newRequest request: URLRequest,
                         completionHandler: @escaping (URLRequest?) -> Void) {
    completionHandler(request)
  }
  
  // MARK: - URLSessionDataDelegate
  
  open func urlSession(_ session: URLSession,
                       dataTask: URLSessionDataTask,
                       didReceive data: Data) {
    self.datas[dataTask.taskIdentifier]?.append(data)
  }
  
  @available(iOS 9.0, OSXApplicationExtension 10.11, *)
  open func urlSession(_ session: URLSession,
                       dataTask: URLSessionDataTask,
                       didBecome streamTask: URLSessionStreamTask) {
    // No default implementation
  }
  
  open func urlSession(_ session: URLSession,
                       dataTask: URLSessionDataTask,
                       didBecome downloadTask: URLSessionDownloadTask) {
    // No default implementation
  }
  
  open func urlSession(_ session: URLSession,
                       dataTask: URLSessionDataTask,
                       willCacheResponse proposedResponse: CachedURLResponse,
                       completionHandler: @escaping (CachedURLResponse?) -> Void) {
    completionHandler(proposedResponse)
  }
  
  open func urlSession(_ session: URLSession,
                       dataTask: URLSessionDataTask,
                       didReceive response: URLResponse,
                       completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    defer {
      completionHandler(.allow)
    }
    
    if let httpResponse = response as? HTTPURLResponse {
      self.responses[dataTask.taskIdentifier] = httpResponse
    }
  }
}
