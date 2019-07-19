import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class AutomaticPersistedQueriesTests: XCTestCase {

  private final let endpoint = "http://localhost:8080/graphql"
  
  func testRequestBody() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _,_ in }
    
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
  
  func testRequestBodyWithVariable() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .jedi)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")

    validatePostBody(with: request,
                     query: query,
                     queryDocument: true,
                     variable: true)
  }
  
  
  func testRequestBodyForAPQsWithVariable() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    validatePostBody(with: request,
                     query: query,
                     persistedQuery: true,
                     variable: true)
  }
  
  func testQueryStringForAPQsUseGetMethod() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _,_ in }
    
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
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true,
                      variable: true)
  }
  
  func testUseGETForQueriesRequest() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       useGETForQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _,_ in }
    
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
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _,_ in }
    
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
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "POST")
    
    validatePostBody(with: request,
                     query: query,
                     persistedQuery: true,
                     variable: true)
  }
  
  func testUseGETForQueriesAPQsRequest() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       useGETForQueries: true,
                                       enableAutoPersistedQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true,
                      variable: true)
  }
  
  func testNotUseGETForQueriesAPQsGETRequest() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true,
                                       useGETForPersistedQueryRetry: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssertEqual(request.url?.host, network.url.host)
    XCTAssertEqual(request.httpMethod, "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true,
                      variable: true)
  }
}

// MARK: Helpers

private func validateUrlParams(with request: URLRequest, query: HeroNameQuery, queryDocument: Bool = false, persistedQuery: Bool = false, variable: Bool = false) {
  guard let url = request.url else {
    XCTFail("URL not valid")
    return
  }
  
  let queryStting = url.queryItems?["query"]
  if queryDocument {
    XCTAssertEqual(queryStting, query.queryDocument)
  } else {
    XCTAssertNil(queryStting)
  }
  
  let variables = url.queryItems?["variables"]
  if variable {
    XCTAssertNotNil(variables)
    XCTAssertEqual(variables, "{\"episode\":\"\(query.episode?.rawValue ?? "")\"}")
  }else{
    XCTAssertNil(variables)
  }
  
  let ext = url.queryItems?["extensions"]
  if persistedQuery {
    guard let ext = ext,
      let data = ext.data(using: .utf8),
      let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
    else {
      XCTFail("extensions json data should not be nil")
      return
    }
    
    guard let persistedQuery = jsonBody["persistedQuery"] as? JSONObject else {
      XCTFail("persistedQuery is missing")
      return
    }
    
    guard let sha256Hash = persistedQuery["sha256Hash"] as? String else {
      XCTFail("sha256Hash is missing")
      return
    }
    
    guard let version = persistedQuery["version"] as? Int else {
      XCTFail("version is missing")
      return
    }
    
    XCTAssertEqual(version, 1)
    XCTAssertEqual(sha256Hash, query.operationIdentifier)
  } else {
    XCTAssertNil(ext)
  }
}

private func validatePostBody(with request: URLRequest, query: HeroNameQuery, queryDocument: Bool = false, persistedQuery: Bool = false, variable: Bool = false) {
  
  guard let httpBody = request.httpBody,
    let jsonBody = try? JSONSerializationFormat.deserialize(data: httpBody) as? JSONObject else {
      XCTFail("httpBody invalid")
      return
  }
  
  let queryStting = jsonBody["query"] as? String
  if queryDocument {
    XCTAssertEqual(queryStting, query.queryDocument)
  }
  
  let variables = jsonBody["variables"] as? JSONObject
  if variable {
    XCTAssertNotNil(variables)
    XCTAssertEqual(variables?["episode"] as? String, query.episode?.rawValue)
  }else{
    XCTAssertNil(variables)
  }
  
  let ext = jsonBody["extensions"] as? JSONObject
  if persistedQuery {
    guard let ext = ext else {
        XCTFail("extensions json data should not be nil")
        return
    }

    guard let persistedQuery = ext["persistedQuery"] as? JSONObject else {
      XCTFail("persistedQuery is missing")
      return
    }
    
    guard let version = persistedQuery["version"] as? Int else {
      XCTFail("version is missing")
      return
    }
    
    guard let sha256Hash = persistedQuery["sha256Hash"] as? String else {
      XCTFail("sha256Hash is missing")
      return
    }
    
    XCTAssertEqual(version, 1)
    XCTAssertEqual(sha256Hash, query.operationIdentifier)
  } else {
    XCTAssertNil(ext)
  }
}

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
