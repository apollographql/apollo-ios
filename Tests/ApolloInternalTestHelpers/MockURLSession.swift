import Foundation
import Apollo
import ApolloAPI

public final class MockURLSessionClient: URLSessionClient {

  @Atomic public var lastRequest: URLRequest?
  @Atomic public var requestCount = 0

  public var jsonData: JSONObject?
  public var data: Data?
  var responseData: Data? {
    if let data = data { return data }
    if let jsonData = jsonData {
      return try! JSONSerializationFormat.serialize(value: jsonData)
    }
    return nil
  }
  public var response: HTTPURLResponse?
  public var error: Error?
  
  private let callbackQueue: DispatchQueue
  
  public init(callbackQueue: DispatchQueue? = nil) {
    self.callbackQueue = callbackQueue ?? .main
  }

  public override func sendRequest(_ request: URLRequest,
                                   rawTaskCompletionHandler: URLSessionClient.RawCompletion? = nil,
                                   completion: @escaping URLSessionClient.Completion) -> URLSessionTask {
    self.$lastRequest.mutate { $0 = request }
    self.$requestCount.increment()
        
    // Capture data, response, and error instead of self to ensure we complete with the current state
    // even if it is changed before the block runs.
    callbackQueue.async { [responseData, response, error] in
      rawTaskCompletionHandler?(responseData, response, error)
      
      if let error = error {
        completion(.failure(error))
      } else {
        guard let data = responseData else {
          completion(.failure(URLSessionClientError.dataForRequestNotFound(request: request)))
          return
        }
        
        guard let response = response else {
          completion(.failure(URLSessionClientError.noHTTPResponse(request: request)))
          return
        }
        
        completion(.success((data, response)))
      }
    }

    let mockTaskType: URLSessionDataTaskMockProtocol.Type = URLSessionDataTaskMock.self
    let mockTask = mockTaskType.init() as! URLSessionDataTaskMock
    return mockTask
  }
}

protocol URLSessionDataTaskMockProtocol {
  init()
}

private final class URLSessionDataTaskMock: URLSessionDataTask, URLSessionDataTaskMockProtocol {

  override func resume() {
    // No-op
  }
}
