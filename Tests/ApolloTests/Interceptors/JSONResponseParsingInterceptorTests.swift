import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import XCTest

class JSONResponseParsingInterceptorTests: XCTestCase {
  func testJSONResponseParsingInterceptorFailsWhenNoResponse() {
    let provider = MockInterceptorProvider([
      JSONResponseParsingInterceptor()
    ])

    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: TestURL.mockServer.url)

    let expectation = self.expectation(description: "Request sent")

    _ = network.send(operation: MockQuery.mock()) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case JSONResponseParsingInterceptor.JSONResponseParsingError.noResponseToParse:
          // This is what we want
          break
        default:
          XCTFail("Unexpected error type: \(error.localizedDescription)")
        }
      }
    }

    self.wait(for: [expectation], timeout: 1)
  }

  func testJSONResponseParsingInterceptorFailsWithEmptyData() {
    let client = MockURLSessionClient(
      response: .mock(),
      data: Data()
    )
    
    let provider = MockInterceptorProvider([
      NetworkFetchInterceptor(client: client),
      JSONResponseParsingInterceptor(),
    ])

    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: TestURL.mockServer.url)

    let expectation = self.expectation(description: "Request sent")

    _ = network.send(operation: MockQuery.mock()) { result in
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
