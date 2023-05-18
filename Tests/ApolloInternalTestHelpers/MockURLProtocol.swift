import Foundation

public class MockURLProtocol: URLProtocol {
  
  public typealias MockRequestHandler = ((URLRequest) throws -> Result<(HTTPURLResponse, Data?), Error>)
  
  // Dictionary of mock request handlers where the `key` is the URL of the request.
  public static var requestHandlers = [URL: MockRequestHandler]()
  
  override class public func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class public func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override public func startLoading() {
    guard let url = request.url,
          let handler = MockURLProtocol.requestHandlers[url] else {
      fatalError("No URL available for URLRequest.")
    }
    
    defer {
      MockURLProtocol.requestHandlers.removeValue(forKey: url)
    }
    
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
