import XCTest
@testable import Apollo
import ApolloTestSupport

class HTTPNetworkTransportDelegateTests: XCTestCase {
  
  func testPrepareRequest() {
    let delegate = TransportDelegate()
    delegate.requestPreparation = { request in
      var mutableRequest = request
      mutableRequest.addValue("value", forHTTPHeaderField: "custom")
      return mutableRequest
    }

    let url = URL(string: "http://localhost/endpoint")!
    MockURLProtocol.nextResponse = MockURLProtocol.Response.make(url: url, response: "{}", statusCode: 200)
    let transport = HTTPNetworkTransport(url: url, configuration: .mock(), sendOperationIdentifiers: false, delegate: delegate)

    let expectation = self.expectation(description: "Trigger request with custom preparation hook")
    _ = transport.send(operation: MockGraphQLQuery()) { (_, _) in
      XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "custom"), "value")
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: 1)
  }
}

private class TransportDelegate: HTTPNetworkTransportDelegate {
  
  var requestPreparation: ((URLRequest) -> URLRequest)?
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport, prepareRequest request: URLRequest, completionHandler: @escaping (URLRequest) -> Void) {
    DispatchQueue.main.async {
      if let requestPreparation = self.requestPreparation {
        completionHandler(requestPreparation(request))
      } else {
        completionHandler(request)
      }
    }
  }
}

private extension URLSessionConfiguration {
  static func mock() -> URLSessionConfiguration {
    let config = URLSessionConfiguration.default
    config.protocolClasses = [MockURLProtocol.self]
    return config
  }
}

private class MockGraphQLQuery: GraphQLQuery {
  
  var operationDefinition: String {
    return "query SampleQuery { object { property } }"
  }
  
  struct Data: GraphQLSelectionSet {
    
    static var selections: [GraphQLSelection] {
      return []
    }
    
    var resultMap: ResultMap
    
    init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }
  }
}
