import XCTest
import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class MaxRetryInterceptorTests: XCTestCase {
  
  func testMaxRetryInterceptorErrorsAfterMaximumRetries() {
    class TestProvider: InterceptorProvider {
      let testInterceptor = BlindRetryingTestInterceptor()
      let retryCount = 15

      func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
      ) -> [any ApolloInterceptor] {
        [
          MaxRetryInterceptor(maxRetriesAllowed: self.retryCount),
          self.testInterceptor
        ]
      }
    }

    let testProvider = TestProvider()
    let network = RequestChainNetworkTransport(interceptorProvider: testProvider,
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    let operation = MockQuery.mock()
    _ = network.send(operation: operation) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTFail("This should not have worked")
      case .failure(let error):
        switch error {
        case MaxRetryInterceptor.RetryError.hitMaxRetryCount(let count, let operationName):
          XCTAssertEqual(count, testProvider.retryCount)
          // There should be one more hit than retries since it will be hit on the original call
          XCTAssertEqual(testProvider.testInterceptor.hitCount, testProvider.retryCount + 1)
          XCTAssertEqual(operationName, MockQuery<MockSelectionSet>.operationName)
        default:
          XCTFail("Unexpected error type: \(error)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }
  
  func testRetryInterceptorDoesNotErrorIfRetriedFewerThanMaxTimes() {
    class TestProvider: InterceptorProvider {
      let testInterceptor = RetryToCountThenSucceedInterceptor(timesToCallRetry: 2)
      let retryCount = 3
      
      let mockClient: MockURLSessionClient = {
        let client = MockURLSessionClient()
        client.jsonData = [:]
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)
        return client
      }()
      
      func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
      ) -> [any ApolloInterceptor] {
        [
          MaxRetryInterceptor(maxRetriesAllowed: self.retryCount),
          self.testInterceptor,
          NetworkFetchInterceptor(client: self.mockClient),
          JSONResponseParsingInterceptor()
        ]
      }
    }

    let testProvider = TestProvider()
    let network = RequestChainNetworkTransport(interceptorProvider: testProvider,
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    let operation = MockQuery.mock()
    _ = network.send(operation: operation) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTAssertEqual(testProvider.testInterceptor.timesRetryHasBeenCalled, testProvider.testInterceptor.timesToCallRetry)
      case .failure(let error):
        XCTFail("Unexpected error: \(error.localizedDescription)")
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }
}
