import Foundation

/// A class to handle URL Session calls that will support background execution,
/// but still (mostly) use callbacks for its primary method of communication.
///
/// **NOTE:** Delegate methods implemented here are not documented inline because
/// Apple has their own documentation for them. Please consult Apple's
/// documentation for how the delegate methods work and what needs to be overridden
/// and handled within your app, particularly in regards to what needs to be called
/// when for background sessions.
open class URLSessionClient: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
  
  public enum URLSessionClientError: Error {
    case noHTTPResponse(request: URLRequest?)
    case sessionBecameInvalidWithoutUnderlyingError
    case dataForRequestNotFound(request: URLRequest?)
    case networkError(data: Data, response: HTTPURLResponse?, underlying: Error)
  }
  
  /// A completion block to be called when the raw task has completed, with the raw information from the session
  public typealias RawCompletion = (Data?, HTTPURLResponse?, Error?) -> Void
  
  /// A completion block returning a result. On `.success` it will contain a tuple with non-nil `Data` and its corresponding `HTTPURLResponse`. On `.failure` it will contain an error.
  public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
  
  private var completionBlocks = Atomic<[Int: Completion]>([:])
  private var rawCompletions = Atomic<[Int: RawCompletion]>([:])
  private var datas = Atomic<[Int: Data]>([:])
  private var responses = Atomic<[Int: HTTPURLResponse]>([:])
  
  /// The raw URLSession being used for this client
  open private(set) var session: URLSession!
  
  /// Designated initializer.
  ///
  /// - Parameters:
  ///   - sessionConfiguration: The `URLSessionConfiguration` to use to set up the URL session.
  ///   - callbackQueue: [optional] The `OperationQueue` to tell the URL session to call back to this class on, which will in turn call back to your class. Defaults to `.main`.
  public init(sessionConfiguration: URLSessionConfiguration = .default,
              callbackQueue: OperationQueue? = .main) {
    super.init()
    self.session = URLSession(configuration: sessionConfiguration,
                              delegate: self,
                              delegateQueue: callbackQueue)
  }
  
  /// Clears underlying dictionaries of any data related to a particular task identifier.
  ///
  /// - Parameter identifier: The identifier of the task to clear.
  open func clearTask(with identifier: Int) {
    self.rawCompletions.value.removeValue(forKey: identifier)
    self.completionBlocks.value.removeValue(forKey: identifier)
    self.datas.value.removeValue(forKey: identifier)
    self.responses.value.removeValue(forKey: identifier)
  }
  
  /// Clears underlying dictionaries of any data related to all tasks.
  ///
  /// Mostly useful for cleanup and/or after invalidation of the `URLSession`.
  open func clearAllTasks() {
    self.rawCompletions.value.removeAll()
    self.completionBlocks.value.removeAll()
    self.datas.value.removeAll()
    self.responses.value.removeAll()
  }
  
  /// The main method to perform a request.
  ///
  /// - Parameters:
  ///   - request: The request to perform.
  ///   - rawTaskCompletionHandler: [optional] A completion handler to call once the raw task is done, so if an Error requires access to the headers, the user can still access these.
  ///   - completion: A completion handler to call when the task has either completed successfully or failed.
  ///
  /// - Returns: The created URLSesssion task, already resumed, because nobody ever remembers to call `resume()`.
  @discardableResult
  open func sendRequest(_ request: URLRequest,
                        rawTaskCompletionHandler: RawCompletion? = nil,
                        completion: @escaping Completion) -> URLSessionTask {
    let dataTask = self.session.dataTask(with: request)
    if let rawCompletion = rawTaskCompletionHandler {
      self.rawCompletions.value[dataTask.taskIdentifier] = rawCompletion
    }
    
    self.completionBlocks.value[dataTask.taskIdentifier] = completion
    self.datas.value[dataTask.taskIdentifier] = Data()
    dataTask.resume()
    
    return dataTask
  }
  
  /// Cancels a given task and clears out its underlying data.
  ///
  /// NOTE: You will not receive any kind of "This was cancelled" error when this is called.
  ///
  /// - Parameter task: The task you wish to cancel.
  open func cancel(task: URLSessionTask) {
    self.clearTask(with: task.taskIdentifier)
    task.cancel()
  }
  
  // MARK: - URLSessionDelegate
  
  open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    let finalError = error ?? URLSessionClientError.sessionBecameInvalidWithoutUnderlyingError
    for block in self.completionBlocks.value.values {
      block(.failure(finalError))
    }
    
    self.clearAllTasks()
  }
  
  @available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
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
    
    guard let completion = self.completionBlocks.value.removeValue(forKey: taskIdentifier) else {
      // No completion blocks, the task has likely been cancelled. Bail out.
      return
    }
    
    let data = self.datas.value[taskIdentifier]
    let response = self.responses.value[taskIdentifier]
    
    if let rawCompletion = self.rawCompletions.value.removeValue(forKey: taskIdentifier) {
      rawCompletion(data, response, error)
    }
    
    guard let finalData = data else {
      // Data is immediately created for a task on creation, so if it's not there, something's gone wrong.
      completion(.failure(URLSessionClientError.dataForRequestNotFound(request: task.originalRequest)))
      return
    }
    
    if let finalError = error {
      completion(.failure(URLSessionClientError.networkError(data: finalData, response: response, underlying: finalError)))
    } else {
      guard let finalResponse = response else {
        completion(.failure(URLSessionClientError.noHTTPResponse(request: task.originalRequest)))
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
  
  @available(iOS 11.0, OSXApplicationExtension 10.13, OSX 10.13, tvOS 11.0, watchOS 4.0, *)
  open func urlSession(_ session: URLSession,
                       task: URLSessionTask,
                       willBeginDelayedRequest request: URLRequest,
                       completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
    completionHandler(.continueLoading, request)
  }
  
  open func urlSession(_ session: URLSession,
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
    self.datas.value[dataTask.taskIdentifier]?.append(data)
  }
  
  @available(iOS 9.0, OSXApplicationExtension 10.11, OSX 10.11, *)
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
      self.responses.value[dataTask.taskIdentifier] = httpResponse
    }
  }
}
