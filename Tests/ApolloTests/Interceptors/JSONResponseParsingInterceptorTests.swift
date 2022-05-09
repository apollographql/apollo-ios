import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import XCTest

class JSONResponseParsingInterceptorTests: XCTestCase {

  func testJSONResponseParsingInterceptorFailsWithEmptyData() {
    class TestProvider: InterceptorProvider {
      let mockClient: MockURLSessionClient = {
        let client = MockURLSessionClient()
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        client.data = Data()
        return client
      }()

      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          JSONResponseParsingInterceptor(),
        ]
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
                                               endpointURL: TestURL.mockServer.url)

    let expectation = self.expectation(description: "Request sent")

    _ = network.send(operation: MockOperation.mock()) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case JSONResponseParsingInterceptor.JSONResponseParsingError.couldNotParseToJSON(let data):
          XCTAssertTrue(data.isEmpty)
        default:
          XCTFail("Unexpected error type: \(error.localizedDescription)")
        }
      }
    }

    self.wait(for: [expectation], timeout: 1)
  }
}
