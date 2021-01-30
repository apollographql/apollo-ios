//
//  InterceptorTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 8/19/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import Apollo
import ApolloTestSupport
import StarWarsAPI

class InterceptorTests: XCTestCase {
  
  // MARK: - Retry Interceptor
  
  func testMaxRetryInterceptorErrorsAfterMaximumRetries() {
    class TestProvider: InterceptorProvider {
      let testInterceptor = BlindRetryingTestInterceptor()
      let retryCount = 15
      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          MaxRetryInterceptor(maxRetriesAllowed: self.retryCount),
          self.testInterceptor,
          NetworkFetchInterceptor(client: MockURLSessionClient()),
        ]
      }
    }

    let testProvider = TestProvider()
    let network = RequestChainNetworkTransport(interceptorProvider: testProvider,
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    let operation = HeroNameQuery()
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
          XCTAssertEqual(operationName, operation.operationName)
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
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 200,
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
      
      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          MaxRetryInterceptor(maxRetriesAllowed: self.retryCount),
          self.testInterceptor,
          NetworkFetchInterceptor(client: self.mockClient),
          LegacyParsingInterceptor(),
        ]
      }
    }

    let testProvider = TestProvider()
    let network = RequestChainNetworkTransport(interceptorProvider: testProvider,
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    let operation = HeroNameQuery()
    _ = network.send(operation: operation) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
        XCTAssertEqual(testProvider.testInterceptor.timesRetryHasBeenCalled, testProvider.testInterceptor.timesToCallRetry)
      case .failure(let error):
        XCTFail("Unexpected error: \(error.localizedDescription)")
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }
  
  // MARK: - Legacy Parsing Interceptor
  
  func testLegacyParsingInterceptorFailsWithEmptyData() {
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
          LegacyParsingInterceptor(),
        ]
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    _ = network.send(operation: HeroNameQuery()) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case LegacyParsingInterceptor.LegacyParsingError.couldNotParseToLegacyJSON(let data):
          XCTAssertTrue(data.isEmpty)
        default:
          XCTFail("Unexpected error type: \(error.localizedDescription)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }
  
  // MARK: - Response Code Interceptor
  
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
      
      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          ResponseCodeInterceptor(),
          LegacyParsingInterceptor()
        ]
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    _ = network.send(operation: HeroNameQuery()) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case LegacyParsingInterceptor.LegacyParsingError.couldNotParseToLegacyJSON(let data):
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
      
      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          ResponseCodeInterceptor(),
          LegacyParsingInterceptor(),
        ]
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    _ = network.send(operation: HeroNameQuery()) { result in
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
          
          XCTAssertEqual(dataString, "{\"data\":{\"hero\":{\"__typename\":\"Human\",\"name\":\"Luke Skywalker\"}}}")
        default:
          XCTFail("Unexpected error type: \(error.localizedDescription)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
  }

  // MARK: - Codable Parsing Interceptor

  func testCodableParsingInterceptorDecodesGraphQLResponse() {
    class TestProvider: InterceptorProvider {
      let mockClient: MockURLSessionClient = {
        let client = MockURLSessionClient()
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 200,
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

      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          NetworkFetchInterceptor(client: self.mockClient),
          CodableParsingInterceptor(decoder: JSONDecoder()),
        ]
      }
    }

    struct TestData: Decodable {
      struct Hero: Decodable {
        var name: String
      }

      var hero: Hero
    }

    struct DecodableSelectionSet<Data: Decodable>: Decodable, GraphQLSelectionSet {
      static var selections: [GraphQLSelection] {
        []
      }

      var data: Data

      var resultMap: ResultMap {
        fatalError()
      }

      init(unsafeResultMap: ResultMap) {
        fatalError()
      }
    }

    class TestQuery: GraphQLQuery {
      typealias Data = DecodableSelectionSet<TestData>

      var operationDefinition: String {
        HeroNameQuery().operationDefinition
      }

      var operationName: String {
        HeroNameQuery().operationName
      }
    }

    let network = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
                                               endpointURL: TestURL.mockServer.url)

    let expectation = self.expectation(description: "Request sent")

    var result: Result<TestData?, Error>?

    _ = network.send(operation: TestQuery()) {
      result = $0.map(\.data?.data)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    if let result = result {
      XCTAssertEqual(try result.get()?.hero.name, "Luke Skywalker")
    }
  }
}
