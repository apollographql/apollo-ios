import Foundation

/// A class to help download things from a given remote URL to a given local file URL
class URLDownloader {
  
  enum DownloaderError: Error, LocalizedError {
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
  
  /// Downloads the contents of a given URL synchronously to the given output URL
  /// - Parameters:
  ///   - url: The URL to download from
  ///   - outputURL: The file URL tou download to
  ///   - timeout: The timeout to use while downloading
  /// - Throws: Any error which occurs during the download
  func downloadSynchronously(with urlRequest: URLRequest,
                             to outputURL: URL,
                             timeout: Double) throws {
    let semaphore = DispatchSemaphore(value: 0)
    var errorToThrow: Error? = DownloaderError.downloadTimedOut(after: timeout)
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      func finished(with finalError: Error?) {
        errorToThrow = finalError
        semaphore.signal()
      }
        
      if let error = error {
        finished(with: error)
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        finished(with: DownloaderError.responseNotHTTPResponse)
        return
      }
      
      guard httpResponse.statusCode == 200 else {
        let dataAsString = String(bytes: data ?? Data(), encoding: .utf8)
        finished(with: DownloaderError.badResponse(code: httpResponse.statusCode, response: dataAsString))
        return
      }
      
      guard let data = data else {
        finished(with: DownloaderError.noDataReceived)
        return
      }
      
      guard !data.isEmpty else {
        finished(with: DownloaderError.emptyDataReceived)
        return
      }
      
      do {
        try FileManager.default.apollo.createContainingFolderIfNeeded(for: outputURL)
        try data.write(to: outputURL)
      } catch (let writeError) {
        finished(with: writeError)
        return
      }
      
      // If we got here, it all worked and it's good to go!
      finished(with: nil)
    }.resume()
    
    _ = semaphore.wait(timeout: .now() + timeout)
    
    if let throwMe = errorToThrow {
      throw throwMe
    } // else, success!
  }
}
