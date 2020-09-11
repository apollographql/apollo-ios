@testable import Apollo
import Dispatch

public final class MockNetworkTransport: RequestChainNetworkTransport {

  private let mockClient: MockURLSessionClient

  public init(body: JSONObject, store: ApolloStore) {
    let testURL = TestURL.mockServer.url
    self.mockClient = MockURLSessionClient()
    self.mockClient.data = try! JSONSerializationFormat.serialize(value: body)
    self.mockClient.response = HTTPURLResponse(url: testURL,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)
    let legacyProvider = LegacyInterceptorProvider(client: self.mockClient,
                                                   store: store)
    super.init(interceptorProvider: legacyProvider,
               endpointURL: TestURL.mockServer.url)
  }
  
  public func updateBody(to body: JSONObject) {
    self.mockClient.data = try! JSONSerializationFormat.serialize(value: body)
  }
}

private final class MockTask: Cancellable {
  func cancel() {
    // no-op
  }
}
