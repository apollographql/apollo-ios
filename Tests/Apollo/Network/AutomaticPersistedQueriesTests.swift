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
                                line: UInt = #line) {
    
    guard let httpBody = request.httpBody,
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
      guard let ext = ext else {
        XCTFail("extensions json data should not be nil",
                file: file,
                line: line)
        return
      }
      
      guard let persistedQuery = ext["persistedQuery"] as? JSONObject else {
        XCTFail("persistedQuery is missing",
                file: file,
                line: line)
        return
      }
      
      guard let version = persistedQuery["version"] as? Int else {
        XCTFail("version is missing",
                file: file,
                line: line)
        return
      }
      
      guard let sha256Hash = persistedQuery["sha256Hash"] as? String else {
        XCTFail("sha256Hash is missing",
                file: file,
                line: line)
        return
      }
      
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
  
  private func validateUrlParams(with request: URLRequest,
                                 query: HeroNameQuery,
                                 queryDocument: Bool = false,
                                 persistedQuery: Bool = false,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
    guard let url = request.url else {
      XCTFail("URL not valid",
              file: file,
              line: line)
      return
    }
    
    let queryString = url.queryItems?["query"]
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
    
    if let variables = url.queryItems?["variables"] {
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
    
    let ext = url.queryItems?["extensions"]
    if persistedQuery {
      guard let ext = ext,
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil",
                  file: file,
                  line: line)
          return
      }
      
      guard let persistedQuery = jsonBody["persistedQuery"] as? JSONObject else {
        XCTFail("persistedQuery is missing",
                file: file,
                line: line)
        return
      }
      
      guard let sha256Hash = persistedQuery["sha256Hash"] as? String else {
        XCTFail("sha256Hash is missing",
                file: file,
                line: line)
        return
      }
      
      guard let version = persistedQuery["version"] as? Int else {
        XCTFail("version is missing",
                file: file,
                line: line)
        return
      }
      
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
  
  func testRequestBody() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!, session: mockSession)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    self.validatePostBody(with: request,
                          query: query,
                          queryDocument: true)
  }
  
  func testRequestBodyWithVariable() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!, session: mockSession)
    let query = HeroNameQuery(episode: .jedi)
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")

    validatePostBody(with: request,
                     query: query,
                     queryDocument: true)
  }
  
  
  func testRequestBodyForAPQsWithVariable() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       enableAutoPersistedQueries: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    validatePostBody(with: request,
                     query: query,
                     persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethod() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethodWithVariable() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true)
  }
  
  func testUseGETForQueriesRequest() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       useGETForQueries: true)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      queryDocument: true)
  }
  
  func testNotUseGETForQueriesRequest() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!, session: mockSession)
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    validatePostBody(with: request,
                     query: query,
                     queryDocument: true)
  }
  
  func testNotUseGETForQueriesAPQsRequest() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       enableAutoPersistedQueries: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    validatePostBody(with: request,
                     query: query,
                     persistedQuery: true)
  }
  
  func testUseGETForQueriesAPQsRequest() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       useGETForQueries: true,
                                       enableAutoPersistedQueries: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true)
  }
  
  func testNotUseGETForQueriesAPQsGETRequest() {
    let mockSession = MockURLSession()
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       session: mockSession,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true)
  }
}

// MARK: Helpers




extension URL {
  var queryItems: [String: String]? {
    return URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .compactMap { $0.dictionaryRepresentation }
      .reduce([String:String]()) { dict, tuple in
        var dict = dict
        tuple.forEach { dict[$0] = $1 }
        return dict
    }
  }
}

extension URLQueryItem {
  var dictionaryRepresentation: [String: String]? {
    if let value = value {
      return [name: value]
    }
    return nil
  }
}
