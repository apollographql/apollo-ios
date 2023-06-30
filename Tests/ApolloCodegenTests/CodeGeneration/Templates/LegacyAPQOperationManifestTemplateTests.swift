import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class LegacyAPQOperationManifestTemplateTests: XCTestCase {
  var subject: LegacyAPQOperationManifestTemplate!

  override func setUp() {
    super.setUp()

    subject = LegacyAPQOperationManifestTemplate()
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
        "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad" : {
          "name" : "TestQuery",
          "source" : "query TestQuery {\\n  test\\n}"
        }
      }
      """

    let operations = [operation].map(OperationManifestItem.init)

    // when
    let rendered = try subject.render(operations: operations)

    expect(rendered).to(equal(expected))
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
        "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad" : {
          "name" : "TestQuery",
          "source" : "query TestQuery {\\n  test\\n}"
        },
        "50ed8cda22910b3b708bc69402626f9fe4f1bbaeafb40df9084d029fade5bab1" : {
          "name" : "TestMutation",
          "source" : "mutation TestMutation {\\n  update {\\n    result\\n  }\\n}"
        },
        "55f75259c34f0ccc6b131d23545d9fa79885c93ec785176bd9b6d3c4062fcaed" : {
          "name" : "TestSubscription",
          "source" : "subscription TestSubscription {\\n  watched\\n}"
        }
      }
      """

    // when
    let rendered = try subject.render(operations: operations)

    expect(rendered).to(equal(expected))
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
        "c5754cef39f339f0a0d0437b8cc58fddd3c147d791441d5fdaa0f8d4265730ff" : {
          "name" : "Friends",
          "source" : "query Friends {\\n  friends {\\n    ...Name\\n  }\\n}\\nfragment Name on Friend {\\n  name\\n}"
        }
      }
      """

    // when
    let rendered = try subject.render(operations: operations)

    expect(rendered).to(equal(expected))
  }
}
