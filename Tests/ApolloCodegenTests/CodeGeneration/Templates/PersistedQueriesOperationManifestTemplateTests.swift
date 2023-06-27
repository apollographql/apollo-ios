import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class PersistedQueriesOperationManifestTemplateTests: XCTestCase {
  var subject: PersistedQueriesOperationManifestTemplate!

  override func setUp() {
    super.setUp()

    subject = PersistedQueriesOperationManifestTemplate()
  }

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Render tests

  func test__render__givenSingleOperation_shouldOutputJSONFormat() throws {
    // given
    let operation = IR.Operation.mock(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    )

    let expected = """
      {
        "format": "apollo-persisted-queries",
        "version": 1,
        "operations": [
          {
            "id": b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad",
            "body" : "query TestQuery {\\n  test\\n}",
            "name" : "TestQuery",
            "type": "query"
          },
        ]
      }
      """

    let operations = [operation].map(OperationManifestItem.init)

    // when
    let rendered = try subject.render(operations: operations)

    expect(rendered).to(equalLineByLine(expected))
  }

  func test__render__givenMultipleOperations_shouldOutputJSONFormat() throws {
    // given
    let operations = [
      IR.Operation.mock(
        name: "TestQuery",
        type: .query,
        source: """
        query TestQuery {
          test
        }
        """
      ),
      IR.Operation.mock(
        name: "TestMutation",
        type: .mutation,
        source: """
        mutation TestMutation {
          update {
            result
          }
        }
        """
      ),
      IR.Operation.mock(
        name: "TestSubscription",
        type: .subscription,
        source: """
        subscription TestSubscription {
          watched
        }
        """
      )
    ].map(OperationManifestItem.init)

    let expected = """
      {
        "format": "apollo-persisted-queries",
        "version": 1,
        "operations": [
          {
            "id": "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad",
            "body" : "query TestQuery {\\n  test\\n}",
            "name" : "TestQuery",
            "type": "query"
          },
          {
            "id": "50ed8cda22910b3b708bc69402626f9fe4f1bbaeafb40df9084d029fade5bab1",
            "body" : "mutation TestMutation {\\n  update {\\n    result\\n  }\\n}",
            "name" : "TestMutation",
            "type": "mutation"
          },
          {
            "id": "55f75259c34f0ccc6b131d23545d9fa79885c93ec785176bd9b6d3c4062fcaed",
            "body" : "subscription TestSubscription {\\n  watched\\n}",
            "name" : "TestSubscription",
            "type": "subscription"
          },
        ]
      }
      """

    // when
    let rendered = try subject.render(operations: operations)

    expect(rendered).to(equalLineByLine(expected))
  }

  func test__render__givenReferencedFragments_shouldOutputJSONFormat() throws {
    // given
    let operations = [
      IR.Operation.mock(
        name: "Friends",
        type: .query,
        source: """
        query Friends {
          friends {
            ...Name
          }
        }
        """,
        referencedFragments: [
          .mock(
            "Name",
            type: .mock(),
            source: """
            fragment Name on Friend {
              name
            }
            """
          )
        ]
      )
    ].map(OperationManifestItem.init)

    let expected = """
      {
        "format": "apollo-persisted-queries",
        "version": 1,
        "operations": [
          {
            "id": "c5754cef39f339f0a0d0437b8cc58fddd3c147d791441d5fdaa0f8d4265730ff",
            "body" : "query Friends {\\n  friends {\\n    ...Name\\n  }\\n}\\nfragment Name on Friend {\\n  name\\n}",
            "name" : "Friends",
            "type": "query"
          },
        ]
      }
      """

    // when
    let rendered = try subject.render(operations: operations)

    expect(rendered).to(equalLineByLine(expected))
  }
}
