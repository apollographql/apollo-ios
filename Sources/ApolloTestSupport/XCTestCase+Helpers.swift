import XCTest

public extension XCTestExpectation {
  /// Private API for accessing the number of times an expectation has been fulfilled.
  var numberOfFulfillments: Int {
    value(forKey: "numberOfFulfillments") as! Int
  }
}

public extension XCTestCase {
  /// Record  the specified`error` as an `XCTIssue`.
  func record(_ error: Error, compactDescription: String? = nil, file: StaticString = #filePath, line: UInt = #line) {
    var issue = XCTIssue(type: .assertionFailure, compactDescription: compactDescription ?? String(describing: error))

    issue.associatedError = error

    let location = XCTSourceCodeLocation(filePath: file, lineNumber: line)
    issue.sourceCodeContext = XCTSourceCodeContext(location: location)

    record(issue)
  }
  
  /// Wrapper around `XCTContext.runActivity` to  allow for future extension.
  func runActivity<Result>(_ name: String, perform: (XCTActivity) throws -> Result) rethrows -> Result {
    return try XCTContext.runActivity(named: name, block: perform)
  }
}

@testable import Apollo

public extension XCTestCase {
  /// Make  an `AsyncResultObserver` for receiving results of the specified GraphQL operation.
  func makeResultObserver<Operation: GraphQLOperation>(for operation: Operation, file: StaticString = #filePath, line: UInt = #line) -> AsyncResultObserver<GraphQLResult<Operation.Data>, Error> {
    return AsyncResultObserver(testCase: self, file: file, line: line)
  }
}
