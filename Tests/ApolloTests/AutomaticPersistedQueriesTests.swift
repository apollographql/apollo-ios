import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class AutomaticPersistedQueriesTests: XCTestCase {

  private static let endpoint = TestURL.mockServer.url

  // MARK: - Mocks
  class HeroNameSelectionSet: MockSelectionSet {
    override class var selections: [Selection] {[
      .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
    ]}

    var hero: Hero? { __data["hero"] }

    class Hero: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String.self),
      ]}

      var name: String { __data["name"] }
    }
  }

  fileprivate enum MockEnum: String, EnumType {
    case NEWHOPE
    case JEDI
    case EMPIRE
  }

  fileprivate class MockHeroNameQuery: MockQuery<HeroNameSelectionSet> {
    override class var document: DocumentType {
      .automaticallyPersisted(
        operationIdentifier: "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671",
        definition: .init("MockHeroNameQuery - Operation Definition"))
    }

    var episode: GraphQLNullable<MockEnum> {
      didSet {
        self.variables = ["episode": episode]
      }
    }

    init(episode: GraphQLNullable<MockEnum> = .none) {
      self.episode = episode
      super.init()
      self.variables = ["episode": episode]
    }
  }

  fileprivate class APQMockMutation: MockMutation<MockSelectionSet> {
    override class var document: DocumentType {
      .automaticallyPersisted(
      operationIdentifier: "4a1250de93ebcb5cad5870acf15001112bf27bb963e8709555b5ff67a1405374",
      definition: .init("APQMockMutation - Operation Definition"))
    }
  }

  // MARK: - Helper Methods
  
  private func validatePostBody<O: GraphQLOperation>(with request: URLRequest,
                                operation: O,
                                queryDocument: Bool = false,
                                persistedQuery: Bool = false,
                                file: StaticString = #filePath,
                                line: UInt = #line) throws {
    
    guard
      let httpBody = request.httpBody,
      let jsonBody = try? JSONSerializationFormat.deserialize(data: httpBody) as? JSONObject else {
        XCTFail("httpBody invalid",
                file: file,
                line: line)
        return
    }
    
    let queryString = jsonBody["query"] as? String
    if queryDocument {
      XCTAssertEqual(queryString,
                     O.definition?.queryDocument,
                     file: file,
                     line: line)
    }
    
    if let query = operation as? MockHeroNameQuery{
      if let variables = jsonBody["variables"] as? JSONObject {
        XCTAssertEqual(variables["episode"] as? String,
                       query.episode.rawValue,
                       file: file,
                       line: line)
      } else {
        XCTFail("variables should not be nil",
                file: file,
                line: line)
      }
    }
    
    let ext = jsonBody["extensions"] as? JSONObject
    if persistedQuery {
      let ext = try XCTUnwrap(ext,
                              "extensions json data should not be nil",
                              file: file,
                              line: line)
      
      let persistedQuery = try XCTUnwrap(ext["persistedQuery"] as? JSONObject,
                                         "persistedQuery is missing",
                                         file: file,
                                         line: line)
      
      let version = try XCTUnwrap(persistedQuery["version"] as? Int,
                                  "version is missing",
                                  file: file,
                                  line: line)

      let sha256Hash = try XCTUnwrap(persistedQuery["sha256Hash"] as? String,
                                     "sha256Hash is missing",
                                     file: file,
                                     line: line)
      
      XCTAssertEqual(version, 1,
                     file: file,
                     line: line)
      XCTAssertEqual(sha256Hash,
                     O.operationIdentifier,
                     file: file,
                     line: line)
    } else {
      XCTAssertNil(ext,
                   "extensions should be nil",
                   file: file,
                   line: line)
    }
  }
  
  private func validateUrlParams(with request: URLRequest,
                                 query: MockHeroNameQuery,
                                 queryDocument: Bool = false,
                                 persistedQuery: Bool = false,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) throws {
    let url = try XCTUnwrap(request.url,
                            "URL not valid",
                            file: file,
                            line: line)
    
    let queryString = url.queryItemDictionary?["query"]
    if queryDocument {
      XCTAssertEqual(queryString,
                     MockHeroNameQuery.definition?.queryDocument,
                     file: file,
                     line: line)
    } else {
      XCTAssertNil(queryString,
                   "query string should be nil",
                   file: file,
                   line: line)
    }
    
    if let variables = url.queryItemDictionary?["variables"] {
      let expectation = expect(file: file, line: line, variables)
      switch query.episode {
      case let .some(episode):
        expectation.to(equal("{\"episode\":\"\(episode.rawValue)\"}"))

      case .none:
        #warning("TODO: write test to test this case actually happens")
        expectation.to(equal("{}"))

      case .null:
        expectation.to(equal("{\"episode\":null}"))
      }
    } else {
      XCTFail("variables should not be nil",
              file: file,
              line: line)
    }
    
    let ext = url.queryItemDictionary?["extensions"]
    if persistedQuery {
      guard
        let ext = ext,
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil",
                  file: file,
                  line: line)
          return
      }
      
      let persistedQuery = try XCTUnwrap(jsonBody["persistedQuery"] as? JSONObject,
                                         "persistedQuery is missing",
                                         file: file,
                                         line: line)
      
      let sha256Hash = try XCTUnwrap(persistedQuery["sha256Hash"] as? String,
                                     "sha256Hash is missing",
                                     file: file,
                                     line: line)
      
      let version = try XCTUnwrap(persistedQuery["version"] as? Int,
                                  "version is missing",
                                  file: file,
                                  line: line)
      
      XCTAssertEqual(version, 1,
                     file: file,
                     line: line)
      XCTAssertEqual(sha256Hash, MockHeroNameQuery.operationIdentifier,
                     file: file,
                     line: line)
    } else {
      XCTAssertNil(ext,
                   "extension should be nil",
                   file: file,
                   line: line)
    }
  }

  
  // MARK: - Tests
  
  func testRequestBody() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery()
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              operation: query,
                              queryDocument: true)
  }
  
  func testRequestBodyWithVariable() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery(episode: .some(.JEDI))
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try validatePostBody(with: request,
                         operation: query,
                         queryDocument: true)
  }
  
  
  func testRequestBodyForAPQsWithVariable() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery(episode: .some(.EMPIRE))
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              operation: query,
                              persistedQuery: true)
  }
  
  func testMutationRequestBodyForAPQs() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true)
    
    let expectation = self.expectation(description: "Mutation sent")
    let mutation = APQMockMutation()
    var lastRequest: URLRequest?
    let _ = network.send(operation: mutation) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "POST")

    try self.validatePostBody(with: request,
                              operation: mutation,
                              persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethod() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true,
                                               useGETForPersistedQueryRetry: true)

    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery()
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethodWithVariable() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true,
                                               useGETForPersistedQueryRetry: true)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery(episode: .some(.EMPIRE))
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
  
  func testUseGETForQueriesRequest() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               additionalHeaders: ["Authorization": "Bearer 1234"],
                                               useGETForQueries: true)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery()
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "GET")
    XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"], "Bearer 1234")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               queryDocument: true)
  }
  
  func testNotUseGETForQueriesRequest() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery()
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              operation: query,
                              queryDocument: true)
  }
  
  func testNotUseGETForQueriesAPQsRequest() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery(episode: .some(.EMPIRE))
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              operation: query,
                              persistedQuery: true)
  }
  
  func testUseGETForQueriesAPQsRequest() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true,
                                               useGETForQueries: true)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery(episode: .some(.EMPIRE))
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 1)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
  
  func testNotUseGETForQueriesAPQsGETRequest() throws {
    let mockClient = MockURLSessionClient()
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(client: mockClient, store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: Self.endpoint,
                                               autoPersistQueries: true,
                                               useGETForPersistedQueryRetry: true)
    
    let expectation = self.expectation(description: "Query sent")
    let query = MockHeroNameQuery(episode: .some(.EMPIRE))
    var lastRequest: URLRequest?
    let _ = network.send(operation: query) { _ in
      lastRequest = mockClient.lastRequest.value
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 2)
    
    let request = try XCTUnwrap(lastRequest, "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.endpointURL.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
}
