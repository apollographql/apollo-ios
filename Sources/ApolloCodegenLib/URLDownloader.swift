import Foundation

/// A protocol to abstract the underlying network provider.
public protocol NetworkSession {

  /// Load data via the abstracted network provider
  ///
  /// - Parameters:
  ///   - urlRequest: A URL request object that provides the URL, cache policy, request type,
  ///   body data or body stream, and so on.
  ///   - completionHandler: The completion handler to call when the load request is complete.
  /// - Returns: The new session data task. This task will already have been started with a call
  /// to `resume`.
  @discardableResult func loadData(
    with urlRequest: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTask?
}

extension URLSession: NetworkSession {
  public func loadData(
    with urlRequest: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTask? {
    let task = dataTask(with: urlRequest) { (data, response, error) in
      completionHandler(data, response, error)
    }
    task.resume()

    return task
  }
}

/// A class to help download things from a given remote URL to a given local file URL
class URLDownloader {
  let session: NetworkSession
  
  enum DownloadError: Error, LocalizedError {
    case badResponse(code: Int, response: String?)
    case emptyDataReceived
    case noDataReceived
    case downloadTimedOut(after: Double)
    case responseNotHTTPResponse
    
    var errorDescription: String? {
      switch self {
      case .badResponse(let code, let response):
        return "Received bad response from server (code \(code)): \(String(describing: response))"
      case .emptyDataReceived:
        return "Empty data was received from the server."
      case .noDataReceived:
        return "No data was received from the server."
      case .downloadTimedOut(let seconds):
        return "Download timed out after \(seconds) seconds."
      case .responseNotHTTPResponse:
        return "The response was not an HTTP Response, something's gone very wonky."
      }
    }
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///   - session: The NetworkSession conforming instance used for downloads, defaults to the
  ///   shared URLSession singleton object.
  init(session: NetworkSession? = nil) {
    self.session = session ?? URLSession.shared
  }
  
  /// Downloads the contents of a given URL synchronously to the given output URL
  /// - Parameters:
  ///   - urlRequest: A URL request object that provides the URL, cache policy, request type,
  ///   body data or body stream, and so on.
  ///   - outputURL: The file URL where the result will be written to.
  ///   - timeout: The timeout value for the download request duration.
  /// - Throws: Any error which occurs during the download.
  func downloadSynchronously(
    _ request: URLRequest,
    to outputURL: URL,
    timeout: Double
  ) throws {
    let semaphore = DispatchSemaphore(value: 0)
    var errorToThrow: Error? = DownloadError.downloadTimedOut(after: timeout)

    session.loadData(with: request) { data, response, error in
      func finished(_ error: Error? = nil) {
        errorToThrow = error
        semaphore.signal()
      }
        
      if let error = error {
        finished(error)
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        finished(DownloadError.responseNotHTTPResponse)
        return
      }
      
      guard httpResponse.statusCode == 200 else {
        let dataAsString = String(bytes: data ?? Data(), encoding: .utf8)
        finished(DownloadError.badResponse(
          code: httpResponse.statusCode,
          response: dataAsString)
        )
        return
      }
      
      guard let data = data else {
        finished(DownloadError.noDataReceived)
        return
      }
      
      guard !data.isEmpty else {
        finished(DownloadError.emptyDataReceived)
        return
      }
      
      do {
        try ApolloFileManager.default.createContainingDirectoryIfNeeded(forPath: outputURL.path)
        try data.write(to: outputURL)

      } catch (let writeError) {
        finished(writeError)
        return
      }
      
      // If we got here, it all worked and it's good to go!
      finished()
    }
    
    _ = semaphore.wait(timeout: .now() + timeout)
    
    if let throwMe = errorToThrow {
      throw throwMe
    } // else, success!
  }
}
