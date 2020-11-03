import XCTest

public extension XCTestExpectation {
  var numberOfFulfillments: Int {
    value(forKey: "numberOfFulfillments") as! Int
  }
}

public extension XCTestCase {
  func record(_ error: Error, compactDescription: String? = nil, file: StaticString = #filePath, line: UInt = #line) {
    var issue = XCTIssue(type: .assertionFailure, compactDescription: compactDescription ?? String(describing: error))

    issue.associatedError = error

    let location = XCTSourceCodeLocation(filePath: file, lineNumber: line)
    issue.sourceCodeContext = XCTSourceCodeContext(location: location)

    record(issue)
  }
  
  func runActivity<Result>(_ name: String, perform: (XCTActivity) throws -> Result) rethrows -> Result {
    return try XCTContext.runActivity(named: name, block: perform)
  }
}

@testable import Apollo

public extension XCTestCase {
  func makeResultObserver<Operation: GraphQLOperation>(for operation: Operation, file: StaticString = #filePath, line: UInt = #line) -> AsyncResultObserver<GraphQLResult<Operation.Data>, Error> {
    return AsyncResultObserver(testCase: self, file: file, line: line)
  }
  
  func expectSuccessfulResult<Success, Failure: Error>(description: String, file: StaticString = #filePath, line: UInt = #line, perform: (@escaping (Result<Success, Failure>) -> Void) -> Void) -> XCTestExpectation {
    let resultObserver = AsyncResultObserver<Success, Failure>(testCase: self, file: file, line: line)
    let expectation = resultObserver.expectation(description: description, file: file, line: line) { result in
      if case .failure(let error) = result {
        throw error
      }
    }
    perform(resultObserver.handler)
    return expectation
  }
}
