import XCTest
@testable import Apollo
import StarWarsAPI

fileprivate extension LinkContext {
  var counter: Int {
    get {
      return self["counter", default: 0]
    }
    set {
      self["counter"] = newValue
    }
  }
}

fileprivate class SetContextLink: NonTerminatingLink {
  let setContext: (LinkContext) -> LinkContext
  
  init(_ setContext: @escaping (LinkContext) -> LinkContext) {
    self.setContext = setContext
  }
  
  func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>> {
    return forward(operation, setContext(context))
  }
  
  static func incrementCounter(by value: Int) -> NonTerminatingLink {
    return SetContextLink { context in
      var newContext = context
      newContext.counter += value
      return newContext
    }
  }
  
  static func with(cancelController: CancelController) -> NonTerminatingLink {
    return SetContextLink { context in
      var newContext = context
      newContext.signal = cancelController.signal
      return newContext
    }
  }
}

fileprivate class SyncLink: TerminatingLink {
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    if context.signal.isCancelled {
      return Promise(rejected: CancelError())
    }
    
    let body: JSONObject = ["counter": context.counter]
    let response = GraphQLResponse(operation: operation, body: body)
    
    return Promise(fulfilled: response)
  }
}

fileprivate class AsyncLink: TerminatingLink {
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    if context.signal.isCancelled {
      return Promise(rejected: CancelError())
    }
    
    return Promise({ (fulfill, reject) in
      DispatchQueue.global().async {
        guard !context.signal.isCancelled else {
          reject(CancelError())
          return
        }
        
        let body: JSONObject = ["counter": context.counter]
        let response = GraphQLResponse(operation: operation, body: body)
        
        fulfill(response)
      }
    })
  }
}

fileprivate class InfiniteLink: TerminatingLink {
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    var swiftIsHappy = true
    return Promise { (fulfill, reject) in
      DispatchQueue.global().async {
        while swiftIsHappy {
          // infinite loop
        }
        
        fulfill(GraphQLResponse(operation: operation, body: [:]))
      }
      
      context.signal.onCancel {
        reject(CancelError())
      }
      
      }.finally {
        swiftIsHappy = false
    }
  }
}

fileprivate class SemaLink: TerminatingLink {
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    return Promise { (fulfill, reject) in
      let sema = DispatchSemaphore(value: 0)
      DispatchQueue.global().async {
        sema.wait()
        
        fulfill(GraphQLResponse(operation: operation, body: [:]))
      }
      
      context.signal.onCancel {
        reject(CancelError())
      }
    }
  }
}

let query = HeroNameQuery()
let mutation = CreateAwesomeReviewMutation()

class LinkTests: XCTestCase {
  func testExecuteLink() {
    let link = SyncLink()
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 0)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testExecuteLinkWithContext() {
    let link = SyncLink()
    
    let expectation = self.expectation(description: "link executed")
    
    var context = LinkContext()
    context.counter = 10
    
    link.execute(operation: query, context: context).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 10)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testExecuteEmptyLink() {
    let expectation = self.expectation(description: "link executed")
    
    emptyLink.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body.count, 0)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testExecutePassthroughLink() {
    let link = passthroughLink.concat(emptyLink)
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body.count, 0)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testConcatLink() {
    let link = SetContextLink.incrementCounter(by: 1).concat(SyncLink())
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 1)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testConcatMultipleLinks() {
    let link = SetContextLink.incrementCounter(by: 1).concat(SetContextLink.incrementCounter(by: 2)).concat(SyncLink())
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 3)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testSplitNonTerminatingLinkFirst() {
    let queryLink = SetContextLink.incrementCounter(by: 1)
    let mutationLink = SetContextLink.incrementCounter(by: -1)
    
    let splitLink = passthroughLink.split(first: queryLink, second: mutationLink) { op in
      op.rootCacheKey == "QUERY_ROOT"
    }
    
    let link = splitLink.concat(SyncLink())
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 1)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testSplitNonTerminatingLinkSecond() {
    let queryLink = SetContextLink.incrementCounter(by: 1)
    let mutationLink = SetContextLink.incrementCounter(by: -1)
    
    let splitLink = passthroughLink.split(first: queryLink, second: mutationLink) { op in
      op.rootCacheKey == "QUERY_ROOT"
    }
    
    let link = splitLink.concat(SyncLink())
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: mutation).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, -1)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testSplitTerminatingLinkFirst() {
    let queryLink = SetContextLink.incrementCounter(by: 1).concat(SyncLink())
    let mutationLink = SetContextLink.incrementCounter(by: -1).concat(SyncLink())
    
    let link = passthroughLink.split(first: queryLink, second: mutationLink) { op in
      op.rootCacheKey == "QUERY_ROOT"
    }
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 1)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testSplitTerminatingLinkSecond() {
    let queryLink = SetContextLink.incrementCounter(by: 1)
    let mutationLink = SetContextLink.incrementCounter(by: -1)
    
    let splitLink = passthroughLink.split(first: queryLink, second: mutationLink) { op in
      op.rootCacheKey == "QUERY_ROOT"
    }
    
    let link = splitLink.concat(SyncLink())
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: mutation).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, -1)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testExecuteAsyncLink() {
    let link = AsyncLink()
    
    let expectation = self.expectation(description: "link executed")
    
    link.execute(operation: query).andThen { response in
      XCTAssertEqual(response.body["counter"] as? Int, 0)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCancelLink() {
    let controller = CancelController()
    
    let link = SetContextLink.with(cancelController: controller).concat(SyncLink())
    
    controller.cancel()
    
    let expectation = self.expectation(description: "link cancelled")
    
    link.execute(operation: query).catch { error in
      expectation.fulfill()
      XCTAssert(error is CancelError)
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testCancelAsyncLink() {
    let controller = CancelController()
    
    let link = SetContextLink.with(cancelController: controller).concat(AsyncLink())
    
    controller.cancel()
    
    let expectation = self.expectation(description: "link cancelled")
    
    link.execute(operation: query).catch { error in
      expectation.fulfill()
      XCTAssert(error is CancelError)
    }
    
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testCancelInfiniteLink() {
    let controller = CancelController()
    
    let link = SetContextLink.with(cancelController: controller).concat(InfiniteLink())
    
    let expectation = self.expectation(description: "link cancelled")
    
    link.execute(operation: query).catch { error in
      expectation.fulfill()
      XCTAssert(error is CancelError)
    }
    
    controller.cancel()
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testCancelSemaLink() {
    let controller = CancelController()
    
    let link = SetContextLink.with(cancelController: controller).concat(SemaLink())
    
    let expectation = self.expectation(description: "link cancelled")
    
    link.execute(operation: query).catch { error in
      expectation.fulfill()
      XCTAssert(error is CancelError)
    }
    
    controller.cancel()
    
    waitForExpectations(timeout: 0.1)
  }
}
