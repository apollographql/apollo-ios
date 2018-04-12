import Foundation

public class MockURLProtocol: URLProtocol {
  
  public static var lastRequest: URLRequest?
  public static var nextResponse: Response?
  
  public enum Response {
    case success(URLResponse, Data)
    case error(Error)
  }
  
  override public class func canInit(with request: URLRequest) -> Bool {
    lastRequest = request
    return true
  }
  
  override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override public func startLoading() {
    DispatchQueue.main.async {
      guard let response = MockURLProtocol.nextResponse else {
        self.client?.urlProtocolDidFinishLoading(self)
        return
      }
      
      switch response {
      case .success(let urlResponse, let data):
        self.client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        self.client?.urlProtocolDidFinishLoading(self)
      case .error(let error):
        self.client?.urlProtocol(self, didFailWithError: error)
      }
    }
  }
  
  override public func stopLoading() {
    // Nothing to do
  }
}

public extension MockURLProtocol.Response {
  
  public static func make(url: URL, response bodyString: String, statusCode: Int) -> MockURLProtocol.Response {
    let data = bodyString.data(using: .utf8)!
    let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return MockURLProtocol.Response.success(urlResponse, data)
  }
}
