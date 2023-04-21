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
    class DataCaptureRequestChain<Operation: GraphQLOperation>: RequestChain {
      var isCancelled: Bool = false
      var completion: (Data?) -> Void

      init(
        _ completion: @escaping (Data?) -> Void
      ) {
        self.completion = completion
      }

      func kickoff<Operation>(
        request: Apollo.HTTPRequest<Operation>,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
      ) {}

      func proceedAsync<Operation>(
        request: Apollo.HTTPRequest<Operation>,
        response: Apollo.HTTPResponse<Operation>?,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
      ) {
        self.completion(response?.rawData)
      }

      func cancel() {}

      func retry<Operation>(
        request: Apollo.HTTPRequest<Operation>,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
      ) {}

      func handleErrorAsync<Operation>(
        _ error: Error,
        request: Apollo.HTTPRequest<Operation>,
        response: Apollo.HTTPResponse<Operation>?,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
      ) {}

      func returnValueAsync<Operation>(
        for request: Apollo.HTTPRequest<Operation>,
        value: Apollo.GraphQLResult<Operation.Data>,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
      ) {}
    }

    var rawData: String = ""
    for _ in 0..<100 {
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

    let expectedData = "{\"data\":{\"ticker\":1}}".data(using: .utf8)
    let chain = DataCaptureRequestChain<MockSubscription<MockSelectionSet>> { data in
      XCTAssertEqual(data, expectedData)
    }

    measure {
      MultipartResponseParsingInterceptor().interceptAsync(
        chain: chain,
        request: request,
        response: response
      ) { _ in }
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
