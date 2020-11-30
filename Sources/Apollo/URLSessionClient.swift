import Foundation
#if !COCOAPODS
import ApolloCore
#endif

/// A class to handle URL Session calls that will support background execution,
/// but still (mostly) use callbacks for its primary method of communication.
///
/// **NOTE:** Delegate methods implemented here are not documented inline because
/// Apple has their own documentation for them. Please consult Apple's
/// documentation for how the delegate methods work and what needs to be overridden
/// and handled within your app, particularly in regards to what needs to be called
/// when for background sessions.
open class URLSessionClient: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
  
  public enum URLSessionClientError: Error, LocalizedError {
    case noHTTPResponse(request: URLRequest?)
    case sessionBecameInvalidWithoutUnderlyingError
    case dataForRequestNotFound(request: URLRequest?)
    case networkError(data: Data, response: HTTPURLResponse?, underlying: Error)
    case sessionInvalidated
    
    public var errorDescription: String? {
      switch self {
      case .noHTTPResponse(let request):
        return "The request did not receive an HTTP response. Request: \(String(describing: request))"
      case .sessionBecameInvalidWithoutUnderlyingError:
        return "The URL session became invalid, but no underlying error was returned."
      case .dataForRequestNotFound(let request):
        return "URLSessionClient was not able to locate the stored data for request \(String(describing: request))"
      case .networkError(_, _, let underlyingError):
        return "A network error occurred: \(underlyingError.localizedDescription)"
      case .sessionInvalidated:
        return "Attempting to create a new request after the session has been invalidated!"
      }
    }
  }
  
  /// A completion block to be called when the raw task has completed, with the raw information from the session
  public typealias RawCompletion = (Data?, HTTPURLResponse?, Error?) -> Void
  
  /// A completion block returning a result. On `.success` it will contain a tuple with non-nil `Data` and its corresponding `HTTPURLResponse`. On `.failure` it will contain an error.
  public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
  
  private var tasks = Atomic<[Int: TaskData]>([:])
  
  /// The raw URLSession being used for this client
  open private(set) var session: URLSession!
  
  private var hasBeenInvalidated = Atomic<Bool>(false)
  
  private var hasNotBeenInvalidated: Bool {
    !self.hasBeenInvalidated.value
  }
  
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
  
  /// Cleans up and invalidates everything related to this session client.
  ///
  /// NOTE: This must be called from the `deinit` of anything holding onto this client in order to break a retain cycle with the delegate.
  public func invalidate() {
    self.hasBeenInvalidated.mutate { $0 = true }
    func cleanup() {
      self.session = nil
      self.clearAllTasks()
    }

    guard let session = self.session else {
      // Session's already gone, just cleanup.
      cleanup()
      return
    }

    session.invalidateAndCancel()
    cleanup()
  }
  
  /// Clears underlying dictionaries of any data related to a particular task identifier.
  ///
  /// - Parameter identifier: The identifier of the task to clear.
  open func clear(task identifier: Int) {
    self.tasks.mutate { $0.removeValue(forKey: identifier) }
  }
  
  /// Clears underlying dictionaries of any data related to all tasks.
  ///
  /// Mostly useful for cleanup and/or after invalidation of the `URLSession`.
  open func clearAllTasks() {
    guard self.tasks.value.apollo.isNotEmpty else {
      // Nothing to clear
      return
    }
    
    self.tasks.mutate { $0.removeAll() }
  }
  
  /// The main method to perform a request.
  ///
  /// - Parameters:
  ///   - request: The request to perform.
  ///   - rawTaskCompletionHandler: [optional] A completion handler to call once the raw task is done, so if an Error requires access to the headers, the user can still access these.
  ///   - completion: A completion handler to call when the task has either completed successfully or failed.
  ///
  /// - Returns: The created URLSession task, already resumed, because nobody ever remembers to call `resume()`.
  @discardableResult
  open func sendRequest(_ request: URLRequest,
                        rawTaskCompletionHandler: RawCompletion? = nil,
                        completion: @escaping Completion) -> URLSessionTask {
    guard self.hasNotBeenInvalidated else {
      completion(.failure(URLSessionClientError.sessionInvalidated))
      return URLSessionTask()
    }
    
    let task = self.session.dataTask(with: request)
    let taskData = TaskData(rawCompletion: rawTaskCompletionHandler,
                            completionBlock: completion)
    
    self.tasks.mutate { $0[task.taskIdentifier] = taskData }
    
    task.resume()
    
    return task
  }
  
  /// Cancels a given task and clears out its underlying data.
  ///
  /// NOTE: You will not receive any kind of "This was cancelled" error when this is called.
  ///
  /// - Parameter task: The task you wish to cancel.
  open func cancel(task: URLSessionTask) {
    self.clear(task: task.taskIdentifier)
    task.cancel()
  }
  
  // MARK: - URLSessionDelegate
  
  open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    let finalError = error ?? URLSessionClientError.sessionBecameInvalidWithoutUnderlyingError
    for task in self.tasks.value.values {
      task.completionBlock(.failure(finalError))
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
    defer {
      self.clear(task: task.taskIdentifier)
    }
    
    guard let taskData = self.tasks.value[task.taskIdentifier] else {
      // No completion blocks, the task has likely been cancelled. Bail out.
      return
    }
    
    let data = taskData.data
    let response = taskData.response
    
    if let rawCompletion = taskData.rawCompletion {
      rawCompletion(data, response, error)
    }
    
    let completion = taskData.completionBlock
    
    if let finalError = error {
      completion(.failure(URLSessionClientError.networkError(data: data, response: response, underlying: finalError)))
    } else {
      guard let finalResponse = response else {
        completion(.failure(URLSessionClientError.noHTTPResponse(request: task.originalRequest)))
        return
      }
      
      completion(.success((data, finalResponse)))
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
    self.tasks.mutate {
      guard let taskData = $0[dataTask.taskIdentifier] else {
        assertionFailure("No data found for task \(dataTask.taskIdentifier), cannot append received data")
        return
      }
      
      taskData.append(additionalData: data)
    }
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
    
    self.tasks.mutate {
      guard let taskData = $0[dataTask.taskIdentifier] else {
        return
      }
      
      taskData.responseReceived(response: response)
    }
  }
}
