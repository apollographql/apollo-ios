import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class AutomaticPersistedQueriesTests: XCTestCase {

  private final let endpoint = "http://localhost:8080/graphql"
  
  // MARK: - Helper Methods
  
  private func validatePostBody(with request: URLRequest,
                                query: HeroNameQuery,
                                queryDocument: Bool = false,
                                persistedQuery: Bool = false,
                                file: StaticString = #file,
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
                     query.queryDocument,
                     file: file,
                     line: line)
    }
    
    if let variables = jsonBody["variables"] as? JSONObject {
      XCTAssertEqual(variables["episode"] as? String,
                     query.episode?.rawValue,
                     file: file,
                     line: line)
    } else {
      XCTFail("variables should not be nil",
              file: file,
              line: line)
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
                     query.operationIdentifier,
                     file: file,
                     line: line)
    } else {
      XCTAssertNil(ext,
                   "extensions should be nil",
                   file: file,
                   line: line)
    }
  }

  private func validatePostBody(with request: URLRequest,
                                mutation: CreateAwesomeReviewMutation,
                                queryDocument: Bool = false,
                                persistedQuery: Bool = false,
                                file: StaticString = #file,
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
                     mutation.queryDocument,
                     file: file,
                     line: line)
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
                     mutation.operationIdentifier,
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
                                 query: HeroNameQuery,
                                 queryDocument: Bool = false,
                                 persistedQuery: Bool = false,
                                 file: StaticString = #file,
                                 line: UInt = #line) throws {
    let url = try XCTUnwrap(request.url,
                            "URL not valid",
                            file: file,
                            line: line)
    
    let queryString = url.queryItemDictionary?["query"]
    if queryDocument {
      XCTAssertEqual(queryString,
                     query.queryDocument,
                     file: file,
                     line: line)
    } else {
      XCTAssertNil(queryString,
                   "query string should be nil",
                   file: file,
                   line: line)
    }
    
    if let variables = url.queryItemDictionary?["variables"] {
      if let episode = query.episode {
        XCTAssertEqual(variables,
                       "{\"episode\":\"\(episode.rawValue)\"}",
                       file: file,
                       line: line)
      } else {
        XCTAssertEqual(variables,
                       "{\"episode\":null}",
                       file: file,
                       line: line)
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
      XCTAssertEqual(sha256Hash, query.operationIdentifier,
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
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!, client: mockClient)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              query: query,
                              queryDocument: true)
  }
  
  func testRequestBodyWithVariable() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!, client: mockClient)
    let query = HeroNameQuery(episode: .jedi)
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")

    try validatePostBody(with: request,
                         query: query,
                         queryDocument: true)
  }
  
  
  func testRequestBodyForAPQsWithVariable() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       enableAutoPersistedQueries: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")

    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              query: query,
                              persistedQuery: true)
  }

  func testMutationRequestBodyForAPQs() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       enableAutoPersistedQueries: true)
    let mutation = CreateAwesomeReviewMutation()
    let _ = network.send(operation: mutation) { _ in }

    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")

    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")

    try self.validatePostBody(with: request,
                              mutation: mutation,
                              persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethod() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    XCTAssertEqual(request.url?.host, network.url.host)
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethodWithVariable() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")

    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
  
  func testUseGETForQueriesRequest() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       useGETForQueries: true)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               queryDocument: true)
  }
  
  func testNotUseGETForQueriesRequest() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!, client: mockClient)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              query: query,
                              queryDocument: true)
  }
  
  func testNotUseGETForQueriesAPQsRequest() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       enableAutoPersistedQueries: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")

    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    try self.validatePostBody(with: request,
                              query: query,
                              persistedQuery: true)
  }
  
  func testUseGETForQueriesAPQsRequest() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       useGETForQueries: true,
                                       enableAutoPersistedQueries: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
  
  func testNotUseGETForQueriesAPQsGETRequest() throws {
    let mockClient = MockURLSessionClient()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       client: mockClient,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    let request = try XCTUnwrap(mockClient.lastRequest,
                                "last request should not be nil")
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    try self.validateUrlParams(with: request,
                               query: query,
                               persistedQuery: true)
  }
}
