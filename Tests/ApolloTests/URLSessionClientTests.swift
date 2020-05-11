import XCTest
@testable import Apollo

class URLSessionClientLiveTests: XCTestCase {
  
  lazy var client = URLSessionClient()
  
  private func request(for endpoint: HTTPBinAPI.Endpoint) -> URLRequest {
    URLRequest(url: endpoint.toURL,
               cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
               timeoutInterval: 30)
  }
  
  func testBasicGet() {
    let request = self.request(for: .get)
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
        XCTAssertEqual(request.url, httpResponse.url)
      }
    }
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testGettingImage() {
    let request = self.request(for: .image)
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
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testGettingBytes() throws {
    let randomInt = Int.random(in: 1...102_400) // 102400 is max from HTTPBin
    let request = self.request(for: .bytes(count: randomInt))
    
    let expectation = self.expectation(description: "GET request for a random amount of data completed")
    self.client.sendRequest(request) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      case .success(let (data, response)):
        XCTAssertEqual(data.count,
                       randomInt,
                       "Expected \(randomInt) bytes, got \(data.count)")
        XCTAssertEqual(request.url, response.url)
      }
    }
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testPostingJSON() throws {
    let testJSON = ["key": "value"]
    let data = try JSONSerialization.data(withJSONObject: testJSON, options: .prettyPrinted)
    
    var request = self.request(for: .post)
    request.httpBody = data
    request.httpMethod = GraphQLHTTPMethod.POST.rawValue
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
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
          let parsed = try HTTPBinResponse(data: data)
          XCTAssertEqual(parsed.json, testJSON)
        } catch {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testCancellingTaskDirectlyCallsCompletionWithError() throws {
    let request = self.request(for: .bytes(count: 102400)) // 102400 is max from HTTPBin
    
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
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testCancellingTaskThroughClientDoesNotCallCompletion() throws {
    let request = self.request(for: .bytes(count: 102400)) // 102400 is max from HTTPBin
    
    let expectation = self.expectation(description: "Cancelled task completed")
    expectation.isInverted = true
    let task = self.client.sendRequest(request) { result in
      // This shouldn't get hit since we cancel the task immediately
      expectation.fulfill()
    }
    
    self.client.cancel(task: task)
    
    self.wait(for: [expectation], timeout: 5)
    
  }
}
