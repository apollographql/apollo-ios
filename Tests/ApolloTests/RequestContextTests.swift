import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class RequestContextTests: XCTestCase {

  struct TestRequestContext: RequestContext {
    let id = "test123"
  }

  struct RequestContextTestInterceptor: ApolloInterceptor {
    let callback: (RequestContext?) -> (Void)

    public var id: String = UUID().uuidString

    init(_ callback: @escaping (RequestContext?) -> (Void)) {
      self.callback = callback
    }

    func interceptAsync<Operation>(
      chain: RequestChain,
      request: HTTPRequest<Operation>,
      response: HTTPResponse<Operation>?,
      completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>
    ) -> Void) {
      callback(request.context)
    }
  }

  func test__context__isPassedThroughRequestChain() {
    let expectation = self.expectation(description: "Context has been passed through")

    let interceptor = RequestContextTestInterceptor { context in
      guard let context = context as? TestRequestContext else {
        XCTFail()
        return
      }

      XCTAssertEqual(context.id, "test123")
      expectation.fulfill()
    }

    let transport = RequestChainNetworkTransport(
      interceptorProvider: MockInterceptorProvider([interceptor]),
      endpointURL: TestURL.mockServer.url
    )

    _ = transport.send(operation: MockSubscription.mock(), context: TestRequestContext()) { result in
      // noop
    }

    wait(for: [expectation], timeout: 1)
  }

  func test_context_isPassedThroughFromClient() {
    let expectation = self.expectation(description: "Context has been passed through")

    let interceptor = RequestContextTestInterceptor { context in
      guard let context = context as? TestRequestContext else {
        XCTFail()
        return
      }

      XCTAssertEqual(context.id, "test123")
      expectation.fulfill()
    }

    let transport = RequestChainNetworkTransport(
      interceptorProvider: MockInterceptorProvider([interceptor]),
      endpointURL: TestURL.mockServer.url
    )

    let store = ApolloStore()
    let client = ApolloClient(networkTransport: transport, store: store)

    client.fetch(query: MockQuery<MockSelectionSet>(), context: TestRequestContext())
    wait(for: [expectation], timeout: 1)
  }

}
