import XCTest
@testable import Apollo
import ApolloInternalTestHelpers
import GitHubAPI

class ParsingPerformanceTests: XCTestCase {

  func testParseResult() throws {
    let query = IssuesAndCommentsForRepositoryQuery()

    let response = try loadResponse(for: query)

    measure {
      whileRecordingErrors {
        let (result, _) = try response.parseResult()

        let data = try XCTUnwrap(result.data)
        XCTAssertEqual(data.repository?.name, "apollo-ios")
      }
    }
  }

  func testParseResultFast() throws {
    let query = IssuesAndCommentsForRepositoryQuery()

    let response = try loadResponse(for: query)

    measure {
      whileRecordingErrors {
        let result = try response.parseResultFast()

        let data = try XCTUnwrap(result.data)
        XCTAssertEqual(data.repository?.name, "apollo-ios")
      }
    }
  }

  // MARK - Helpers

  func loadResponse<Query: GraphQLQuery>(for query: Query, file: StaticString = #file, line: UInt = #line) throws -> GraphQLResponse<Query.Data> {
    let bundle = Bundle(for: type(of: self))

    guard let url = bundle.url(forResource: Query.operationName, withExtension: "json") else {
      throw XCTFailure("Missing response file for query: \(Query.operationName)", file: file, line: line)
    }

    let data = try Data(contentsOf: url)
    let body = try JSONSerialization.jsonObject(with: data, options: []) as! JSONObject

    return GraphQLResponse(operation: query, body: body)
  }
}
