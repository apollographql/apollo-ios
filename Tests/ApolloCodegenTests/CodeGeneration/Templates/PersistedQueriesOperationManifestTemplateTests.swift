import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class PersistedQueriesOperationManifestTemplateTests: XCTestCase {
  var subject: PersistedQueriesOperationManifestTemplate!

  override func setUp() {
    super.setUp()

    subject = PersistedQueriesOperationManifestTemplate(config: .init(config: .mock()))
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
        "format": "apollo-persisted-query-manifest",
        "version": 1,
        "operations": [
          {
            "id": "8ed9fcbb8ef3c853ad0ecdc920eb8216608bd7c3b32258744e9289ec0372eb30",
            "body": "query TestQuery { test }",
            "name": "TestQuery",
            "type": "query"
          }
        ]
      }
      """

    let operations = [operation].map(OperationManifestItem.init)

    // when
    let rendered = subject.render(operations: operations)

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
        "format": "apollo-persisted-query-manifest",
        "version": 1,
        "operations": [
          {
            "id": "8ed9fcbb8ef3c853ad0ecdc920eb8216608bd7c3b32258744e9289ec0372eb30",
            "body": "query TestQuery { test }",
            "name": "TestQuery",
            "type": "query"
          },
          {
            "id": "551253009bea9350463d15e24660e8a935abc858cd161623234fb9523b0c0717",
            "body": "mutation TestMutation { update { result } }",
            "name": "TestMutation",
            "type": "mutation"
          },
          {
            "id": "9b56a2829263b4d81b4eb9865470a6971c8e40e126e2ff92db51f15d0a4cb7ba",
            "body": "subscription TestSubscription { watched }",
            "name": "TestSubscription",
            "type": "subscription"
          }
        ]
      }
      """

    // when
    let rendered = subject.render(operations: operations)

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

    let expected = #"""
      {
        "format": "apollo-persisted-query-manifest",
        "version": 1,
        "operations": [
          {
            "id": "efc7785ac9768b2be96e061911b97c9c898df41561dda36d9435e94994910f67",
            "body": "query Friends { friends { ...Name } }\nfragment Name on Friend { name }",
            "name": "Friends",
            "type": "query"
          }
        ]
      }
      """#

    // when
    let rendered = subject.render(operations: operations)

    expect(rendered).to(equalLineByLine(expected))
  }

  func test__render__givenOperations_shouldOutputJSONFormatBodyFormatted() throws {
    // given
    subject = PersistedQueriesOperationManifestTemplate(
      config: .init(config: .mock())
    )

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

    let expected = #"""
      {
        "format": "apollo-persisted-query-manifest",
        "version": 1,
        "operations": [
          {
            "id": "efc7785ac9768b2be96e061911b97c9c898df41561dda36d9435e94994910f67",
            "body": "query Friends { friends { ...Name } }\nfragment Name on Friend { name }",
            "name": "Friends",
            "type": "query"
          }
        ]
      }
      """#

    // when
    let rendered = subject.render(operations: operations)

    expect(rendered).to(equalLineByLine(expected))
  }
}
