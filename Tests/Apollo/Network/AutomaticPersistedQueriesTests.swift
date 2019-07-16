import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class HttpNetworkTransportTests: XCTestCase {

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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "POST")
    
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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "POST")

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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "POST")
    
    validatePostBody(with: request,
                     query: query,
                     persistedQuery: true,
                     variable: true)
  }
  
  func testQueryStringForAPQsUseGetMethod() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true,
                                       useHttpGetMethodForPersistedQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery()
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssert(request.url?.host == network.url.host)
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true)
  }
  
  func testQueryStringForAPQsUseGetMethodWithVariable() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true,
                                       useHttpGetMethodForPersistedQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "GET")
    
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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "GET")
    
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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "POST")
    
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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "POST")
    
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
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true,
                      variable: true)
  }
  
  func testNotUseGETForQueriesAPQsGETRequest() {
    let network = HTTPNetworkTransport(url: URL(string: endpoint)!,
                                       enableAutoPersistedQueries: true,
                                       useHttpGetMethodForPersistedQueries: true)
    let mockSession = MockURLSession()
    network.session = mockSession
    let query = HeroNameQuery(episode: .empire)
    let _ = network.send(operation: query) { _,_ in }
    
    guard let request = mockSession.lastRequest else {
      XCTFail("last request should not be nil")
      return
    }
    XCTAssert(request.url?.host == network.url.host)
    XCTAssert(request.httpMethod == "GET")
    
    validateUrlParams(with: request,
                      query: query,
                      persistedQuery: true,
                      variable: true)
  }
}

// MARK: Helpers

private func validateUrlParams(with request: URLRequest,
                               query: HeroNameQuery,
                               queryDocument: Bool = false,
                               persistedQuery: Bool = false,
                               variable: Bool = false
                               ) {
  guard let url = request.url else {
    XCTFail("URL not valid")
    return
  }
  
  let queryStting = url.queryItems?["query"]
  if queryDocument {
    XCTAssert(queryStting == query.queryDocument)
  } else {
    XCTAssertNil(queryStting)
  }
  
  let variables = url.queryItems?["variables"]
  if variable {
    XCTAssertNotNil(variables)
    XCTAssert(variables! == "{\"episode\":\"\(query.episode!.rawValue)\"}")
  }else{
    XCTAssertNil(variables)
  }
  
  let ext = url.queryItems?["extensions"]
  if persistedQuery {
    XCTAssertNotNil(ext)
    
    let data = ext!.data(using: .utf8)!
    let jsonBody = try! JSONSerializationFormat.deserialize(data: data) as! JSONObject
    let persistedQuery = jsonBody["persistedQuery"] as? JSONObject
    XCTAssertNotNil(persistedQuery)
    
    let sha256Hash = persistedQuery!["sha256Hash"] as? String
    let version = persistedQuery!["version"] as? Int
    
    XCTAssert(version == 1)
    XCTAssert(sha256Hash == query.operationIdentifier!)
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
    XCTAssert(queryStting == query.queryDocument)
  }
  
  let variables = jsonBody["variables"] as? JSONObject
  if variable {
    XCTAssertNotNil(variables)
    XCTAssert(variables?["episode"] as? String == query.episode?.rawValue)
  }
  
  let ext = jsonBody["extensions"] as? JSONObject
  if persistedQuery {
    XCTAssertNotNil(ext)
    let persistedQuery = ext?["persistedQuery"] as? JSONObject
    let version = persistedQuery?["version"] as? Int
    let sha256Hash = persistedQuery?["sha256Hash"] as? String
    
    XCTAssert(version == 1)
    XCTAssert(sha256Hash == query.operationIdentifier)
  } else {
    XCTAssertNil(ext)
  }
}

private final class MockURLSession: URLSession {
  private (set) var lastRequest: URLRequest?

  override public func dataTask(with request: URLRequest) -> URLSessionDataTask {
    lastRequest = request
    return URLSessionDataTaskMock()
  }
  
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    lastRequest = request
    return URLSessionDataTaskMock()
  }
}

private final class URLSessionDataTaskMock: URLSessionDataTask {
  override func resume() {
  }
}

extension URL {
  var queryItems: [String: String]? {
    return URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .compactMap { $0.dictionaryRepresentation }
      .reduce([:], +)
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

private func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
  var result = lhs
  rhs.forEach{ result[$0] = $1 }
  return result
}
