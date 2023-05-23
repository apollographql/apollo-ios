import XCTest
@testable import Apollo
import ApolloInternalTestHelpers

class URLSessionClientTests: XCTestCase {
  
  var client: URLSessionClient!
  var sessionConfiguration: URLSessionConfiguration!

  override func setUp() {
    super.setUp()
    Self.testObserver.start()
    sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.protocolClasses = [MockURLProtocol<Self>.self]
    client = URLSessionClient(sessionConfiguration: sessionConfiguration)
  }

  override func tearDown() {
    client = nil
    sessionConfiguration = nil
    super.tearDown()
  }
  
  private func request(
    for url: URL,
    responseData: Data?,
    statusCode: Int,
    httpVersion: String? = nil,
    headerFields: [String: String]? = nil
  ) -> URLRequest {
    let request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringCacheData,
                             timeoutInterval: 10)
    
    Self.requestHandlers[url] = { request in
      guard let requestURL = request.url else {
        throw URLError(.badURL)
      }
      
      let response = HTTPURLResponse(url: requestURL,
                                     statusCode: statusCode,
                                     httpVersion: httpVersion,
                                     headerFields: headerFields)
      return .success((response!, responseData))
    }
    
    return request
  }
  
  func testBasicGet() {
    let url = URL(string: "http://www.test.com/basicget")!
    let stringResponse = "Basic GET Response Data"
    let request = self.request(for: url,
                               responseData: stringResponse.data(using: .utf8),
                               statusCode: 200)
    let expectation = self.expectation(description: "Basic GET request completed")
    self.client.sendRequest(request) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      case .success(let (data, httpResponse)):
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(String(data: data, encoding: .utf8), stringResponse)
        XCTAssertEqual(request.url, httpResponse.url)
        XCTAssertEqual(httpResponse.statusCode, 200)
      }
    }
    
    self.wait(for: [expectation], timeout: 5)
  }
  
  func testGettingImage() {
    let url = URL(string: "http://www.test.com/gettingImage")!
    #if os(macOS)
    let responseImg = NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)
    let responseData = responseImg?.tiffRepresentation
    #else
    guard let responseImg = UIImage(systemName: "pencil") else {
      XCTFail("Failed to create UIImage from system name.")
      return
    }
    let responseData = responseImg.pngData()
    #endif
    let headerFields = ["Content-Type": "image/jpeg"]
    let request = self.request(for: url,
                               responseData: responseData,
                               statusCode: 200,
                               headerFields: headerFields)
    
    let expectation = self.expectation(description: "GET request for image completed")
    self.client.sendRequest(request) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      case .success(let (data, httpResponse)):
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(httpResponse.allHeaderFields["Content-Type"] as! String, "image/jpeg")
        #if os(macOS)
          let image = NSImage(data: data)
          XCTAssertNotNil(image)
        #else
          let image = UIImage(data: data)
          XCTAssertNotNil(image)
        #endif
        XCTAssertEqual(request.url, httpResponse.url)
      }
    }

    self.wait(for: [expectation], timeout: 5)
  }
  
  func testPostingJSON() throws {
    let testJSON = ["key": "value"]
    let data = try JSONSerialization.data(withJSONObject: testJSON, options: .prettyPrinted)
    let url = URL(string: "http://www.test.com/postingJSON")!
    let headerFields = ["Content-Type": "application/json"]
    
    var request = self.request(for: url,
                               responseData: data,
                               statusCode: 200,
                               headerFields: headerFields)
    request.httpBody = data
    request.httpMethod = GraphQLHTTPMethod.POST.rawValue

    let expectation = self.expectation(description: "POST request with JSON completed")
    self.client.sendRequest(request) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      case .success(let (data, httpResponse)):
        XCTAssertEqual(request.url, httpResponse.url)

        do {
          let parsedJSON = try JSONSerialization.jsonObject(with: data) as! [String : String]
          XCTAssertEqual(parsedJSON, testJSON)
        } catch {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }

    self.wait(for: [expectation], timeout: 5)
  }
  
  func testCancellingTaskDirectlyCallsCompletionWithError() throws {
    let url = URL(string: "http://www.test.com/cancelTaskDirectly")!
    let request = request(for: url,
                          responseData: nil,
                          statusCode: -1)

    let expectation = self.expectation(description: "Cancelled task completed")
    let task = self.client.sendRequest(request) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .failure(let error):
        switch error {
        case URLSessionClient.URLSessionClientError.networkError(let data, let httpResponse, let underlying):
          XCTAssertTrue(data.isEmpty)
          XCTAssertNil(httpResponse)
          let nsError = underlying as NSError
          XCTAssertEqual(nsError.domain, NSURLErrorDomain)
          XCTAssertEqual(nsError.code, NSURLErrorCancelled)
        default:
          XCTFail("Unexpected error: \(error)")
        }
      case .success:
        XCTFail("Task succeeded when it should have been cancelled!")
      }
    }

    task.cancel()

    self.wait(for: [expectation], timeout: 5)
  }
  
  func testCancellingTaskThroughClientDoesNotCallCompletion() throws {
    let url = URL(string: "http://www.test.com/cancelThroughClient")!
    let request = request(for: url,
                          responseData: nil,
                          statusCode: -1)

    let expectation = self.expectation(description: "Cancelled task completed")
    expectation.isInverted = true
    let task = self.client.sendRequest(request) { result in
      // This shouldn't get hit since we cancel the task immediately
      expectation.fulfill()
    }

    self.client.cancel(task: task)

    self.wait(for: [expectation], timeout: 5)

  }
  
  func testMultipleSimultaneousRequests() {
    let expectation = self.expectation(description: "request sent, response received")
    let iterations = 20
    expectation.expectedFulfillmentCount = iterations
    @Atomic var taskIDs: [Int] = []
    
    var responseStrings = [Int: String]()
    var requests = [Int: URLRequest]()
    for i in 0..<iterations {
      let url = URL(string: "http://www.test.com/multipleSimultaneousRequests\(i)")!
      let responseStr = "Simultaneous Request \(i)"
      let request = self.request(for: url,
                                 responseData: responseStr.data(using: .utf8),
                                 statusCode: 200)
      responseStrings[i] = responseStr
      requests[i] = request
    }

    DispatchQueue.concurrentPerform(iterations: iterations, execute: { index in
      guard let request = requests[index] else {
        XCTFail("Unable to find URLRequest")
        return
      }
      let task = self.client.sendRequest(request) { result in
        let responseStr = responseStrings[index]
        switch result {
        case .success((let data, let response)):
          XCTAssertEqual(response.url, request.url)
          XCTAssertFalse(data.isEmpty)
          let httpResponseStr = String(data: data, encoding: .utf8)
          XCTAssertEqual(responseStr, httpResponseStr)
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }

        DispatchQueue.main.async {
          expectation.fulfill()
        }
      }

      $taskIDs.mutate { $0.append(task.taskIdentifier) }
    })

    self.wait(for: [expectation], timeout: 30)

    // Were the correct number of tasks created?
    XCTAssertEqual(taskIDs.count, iterations)

    // Using a set to unique, are all task IDs different values?)
    let set = Set(taskIDs)
    XCTAssertEqual(set.count, iterations)
  }
  
  func testInvalidatingClientAndThenTryingToSendARequestReturnsAppropriateError() {
    let client = URLSessionClient(sessionConfiguration: sessionConfiguration)
    client.invalidate()

    let url = URL(string: "http://www.test.com/invalidatedRequestTest")!
    let request = request(for: url,
                          responseData: nil,
                          statusCode: 400)
    let expectation = self.expectation(description: "Basic GET request completed")
    client.sendRequest(request) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .failure(let error):
        switch error {
        case URLSessionClient.URLSessionClientError.sessionInvalidated:
          // This is what we want
          break
        default:
          XCTFail("Unexpected error: \(error)")
        }
      case .success:
        XCTFail("This should not have succeeded")
      }
    }

    self.wait(for: [expectation], timeout: 5)
  }
  
}

extension URLSessionClientTests: MockRequestProvider {
  
  private static let testObserver = TestObserver() { _ in
    requestHandlers = [:]
  }
  
  public static var requestHandlers = [URL: MockRequestHandler]()
  
}
