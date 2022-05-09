@testable import ApolloCodegenLib

public final class MockNetworkSession: NetworkSession {
  let statusCode: Int
  let data: Data?
  let error: Error?
  let abandon: Bool

  public init(statusCode: Int, data: Data? = nil, error: Error? = nil, abandon: Bool = false) {
    self.statusCode = statusCode
    self.data = data
    self.error = error
    self.abandon = abandon
  }

  public func loadData(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
    guard !abandon else { return nil }

    let response = HTTPURLResponse(url: urlRequest.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    completionHandler(data, response, error)

    return nil
  }
}
