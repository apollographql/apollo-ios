import XCTest
@testable import Apollo
import ApolloTestSupport

class ExecutionTests: XCTestCase {
  static let defaultWaitTimeout = 0.5

  var store: ApolloStore!
  var server: MockGraphQLServer!
  var transport: NetworkTransport!
  var client: ApolloClient!

  override func setUp() {
    store = ApolloStore()
    server = MockGraphQLServer()
    transport = MockNetworkTransport(server: server, store: store)
    client = ApolloClient(networkTransport: transport, store: store)
  }

  override func tearDown() {
    client = nil
    transport = nil
    server = nil
    store = nil
  }

  func testClearCacheCompletion_givenNoCallbackQueue_shouldCallbackOnMainQueue() throws {
    let completionCallbackExpectation = expectation(description: "clearCache completion callback on main queue")
    client.clearCache() { result in
      XCTAssertTrue(Thread.isMainThread)

      completionCallbackExpectation.fulfill()
    }

    wait(for: [completionCallbackExpectation], timeout: Self.defaultWaitTimeout)
  }

  func testCacheClearCompletion_givenCustomCallbackQueue_shouldCallbackOnCustomQueue() throws {
    let label = "CustomQueue"
    let queue = DispatchQueue(label: label)
    let key = DispatchSpecificKey<String>()
    queue.setSpecific(key: key, value: label)

    let completionCallbackExpectation = expectation(description: "clearCache completion callback on custom queue")
    client.clearCache(callbackQueue: queue) { result in
      XCTAssertEqual(DispatchQueue.getSpecific(key: key), label)

      completionCallbackExpectation.fulfill()
    }

    wait(for: [completionCallbackExpectation], timeout: Self.defaultWaitTimeout)
  }
}
