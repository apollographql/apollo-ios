import Foundation

public class MockURLProtocol<RequestProvider: MockRequestProvider>: URLProtocol {
  
  override class public func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class public func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override public func startLoading() {
    guard let url = request.url,
          let handler = RequestProvider.requestHandlers[url] else {
      fatalError("No URL available for URLRequest.")
    }
    
    defer {
      RequestProvider.requestHandlers.removeValue(forKey: url)
    }
    
    // Provide random response delay between 0 and 1 seconds
    Thread.sleep(forTimeInterval: Double.random(in: 0.0...1.0))
    
    do {
      let result = try handler(request)
      
      switch result {
      case let .success((response, data)):
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let data = data {
          client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
      case let .failure(error):
        client?.urlProtocol(self, didFailWithError: error)
      }
      
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override public func stopLoading() {
  }
  
}

public protocol MockRequestProvider {
  typealias MockRequestHandler = ((URLRequest) throws -> Result<(HTTPURLResponse, Data?), Error>)
  
  // Dictionary of mock request handlers where the `key` is the URL of the request.
  static var requestHandlers: [URL: MockRequestHandler] { get set }
}
