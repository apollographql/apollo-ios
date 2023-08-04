import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import XCTest

class ResponseCodeInterceptorTests: XCTestCase {
  func testResponseCodeInterceptorLetsAnyDataThroughWithValidResponseCode() {
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

      func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
      ) -> [any ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          ResponseCodeInterceptor(),
          JSONResponseParsingInterceptor()
        ]
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
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

  func testResponseCodeInterceptorDoesNotLetDataThroughWithInvalidResponseCode() {
    class TestProvider: InterceptorProvider {
      let mockClient: MockURLSessionClient = {
        let client = MockURLSessionClient()
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 401,
                                          httpVersion: nil,
                                          headerFields: nil)
        let json = [
          "data": [
            "hero": [
              "name": "Luke Skywalker",
              "__typename": "Human"
            ]
          ]
        ]
        let data = try! JSONSerializationFormat.serialize(value: json)
        client.data = data
        return client
      }()

      func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
      ) -> [any ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          ResponseCodeInterceptor(),
          JSONResponseParsingInterceptor(),
        ]
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
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
        case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(response: let response, let rawData):
          XCTAssertEqual(response?.statusCode, 401)

          guard
            let data = rawData,
            let dataString = String(bytes: data, encoding: .utf8) else {
            XCTFail("Incorrect data returned with error")
            return
          }
          
          guard
            let castError = error as? ResponseCodeInterceptor.ResponseCodeError,
            let dataEntry = castError.graphQLError?["data"] as? JSONObject,
            let heroEntry = dataEntry["hero"] as? JSONObject,
            let typeName = heroEntry["__typename"] as? String,
            let heroName = heroEntry["name"] as? String
          else {
            XCTFail("Invalid GraphQL Error")
            return
          }
          XCTAssertEqual("GraphQL Error", castError.graphQLError?.description)
          XCTAssertEqual("Human", typeName)
          XCTAssertEqual("Luke Skywalker", heroName)
          
          XCTAssertEqual(dataString, "{\"data\":{\"hero\":{\"__typename\":\"Human\",\"name\":\"Luke Skywalker\"}}}")
        default:
          XCTFail("Unexpected error type: \(error.localizedDescription)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }
  
  func testResponseCodeInterceptorDoesNotHaveGraphQLError() {
    class TestProvider: InterceptorProvider {
      let mockClient: MockURLSessionClient = {
        let client = MockURLSessionClient()
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 401,
                                          httpVersion: nil,
                                          headerFields: nil)
        client.data = "Not a GraphQL Error".data(using: .utf8)
        return client
      }()
      
      func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
      ) -> [any ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          ResponseCodeInterceptor(),
          JSONResponseParsingInterceptor(),
        ]
      }
    }
    
    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
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
        case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(response: let response, let rawData):
          XCTAssertEqual(response?.statusCode, 401)
          
          guard
            let data = rawData,
            let dataString = String(bytes: data, encoding: .utf8) else {
            XCTFail("Incorrect data returned with error")
            return
          }
          
          guard let castError = error as? ResponseCodeInterceptor.ResponseCodeError else {
            XCTFail("It should be a ResponseCodeError")
            return
          }
          
          XCTAssertNil(castError.graphQLError)
          
          XCTAssertEqual(dataString, "Not a GraphQL Error")
        default:
          XCTFail("Unexpected error type: \(error.localizedDescription)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }
}
