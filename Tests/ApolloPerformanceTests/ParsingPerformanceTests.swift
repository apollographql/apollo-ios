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

  func testMultipartResponseParsingInterceptor() throws {
    var rawData: String = ""
    for _ in 0..<1000 {
      rawData.append("""
        --graphql
        content-type: application/json

        {
          "payload": {
            "data": {
              "ticker": 1
            }
          }
        }
        --graphql
        """)
    }

    let operation = MockSubscription.mock()
    let request = JSONRequest(
      operation: operation,
      graphQLEndpoint: TestURL.mockServer.url,
      clientName: "ApolloPerformanceTest",
      clientVersion: "0",
      additionalHeaders: [
        "Accept" : "multipart/mixed;boundary=\"graphql\";subscriptionSpec=1.0,application/json",
      ])
    let response = HTTPResponse<MockSubscription<MockSelectionSet>>(
      response: HTTPURLResponse(
        url: TestURL.mockServer.url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: [
          "Content-Type": "multipart/mixed;boundary=graphql",
        ])!,
      rawData: rawData.crlfFormattedData(),
      parsedResponse: nil)
    let chain = ResponseCaptureRequestChain()

    let expectedData = "{\"data\":{\"ticker\":1}}".data(using: .utf8)

    measure {
      MultipartResponseParsingInterceptor().interceptAsync(
        chain: chain,
        request: request,
        response: response
      ) { _ in }

      XCTAssertEqual(chain.data, expectedData)
    }
  }

  // MARK - Helpers

  func loadResponse<Query: GraphQLQuery>(
    for query: Query,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> GraphQLResponse<Query.Data> {
    let bundle = Bundle(for: type(of: self))

    guard let url = bundle.url(forResource: Query.operationName, withExtension: "json") else {
      throw XCTFailure("Missing response file for query: \(Query.operationName)",
                       file: file,
                       line: line)
    }

    let data = try Data(contentsOf: url)
    let body = try JSONSerialization.jsonObject(with: data, options: []) as! JSONObject

    return GraphQLResponse(operation: query, body: body)
  }
}
