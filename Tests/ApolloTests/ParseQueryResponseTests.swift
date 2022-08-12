import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class ParseQueryResponseTests: XCTestCase {

  // MARK: - Response Extensions

  func testExtensionsEntryNotNullWhenProvidedInResponseAccompanyingDataEntry() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "data": ["human": NSNull()],
      "extensions": [:]
    ])

    let (result, _) = try response.parseResult()

    XCTAssertNotNil(result.extensions)
  }

  func testExtensionsValuesWhenPopulatedInResponse() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "data": ["human": NSNull()],
      "extensions": ["parentKey": ["childKey": "someValue"]]
    ])

    let (result, _) = try response.parseResult()
    let extensionsDictionary = result.extensions
    let childDictionary = extensionsDictionary?["parentKey"] as? JSONObject

    XCTAssertNotNil(extensionsDictionary)
    XCTAssertNotNil(childDictionary)
    XCTAssertEqual(childDictionary, ["childKey": "someValue"])
  }

  func testExtensionsEntryNullWhenNotProvidedInResponse() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "data": ["human": NSNull()]
    ])

    let (result, _) = try response.parseResult()

    XCTAssertNil(result.extensions)
  }

  func testExtensionsEntryNotNullWhenDataEntryNotProvidedInResponse() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "extensions": [:]
    ])

    let (result, _) = try response.parseResult()

    XCTAssertNotNil(result.extensions)
  }

  // MARK: - Error responses

  func testErrorResponseWithoutLocation() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
        ]
      ]
      ])

    let (result, _) = try response.parseResult()

    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertNil(result.errors?.first?.locations)
  }

  func testErrorResponseWithLocation() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
          "locations": [
            ["line": 1, "column": 2]
          ]
        ]
      ]
    ])

    let (result, _) = try response.parseResult()

    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertEqual(result.errors?.first?.locations?.first?.line, 1)
    XCTAssertEqual(result.errors?.first?.locations?.first?.column, 2)
  }

  func testErrorResponseWithCustomError() throws {
    let query = MockQuery.mock()

    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
          "userMessage": "Some message"
        ]
      ]
    ])

    let (result, _) = try response.parseResult()

    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertEqual(result.errors?.first?["userMessage"] as? String, "Some message")
  }
}
