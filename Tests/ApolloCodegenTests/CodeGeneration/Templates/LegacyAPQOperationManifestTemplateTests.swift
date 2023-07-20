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
        "8ed9fcbb8ef3c853ad0ecdc920eb8216608bd7c3b32258744e9289ec0372eb30" : {
          "name": "TestQuery",
          "source": "query TestQuery { test }"
        }
      }
      """

    let operations = [operation].map(OperationManifestItem.init)

    // when
    let rendered = subject.render(operations: operations)

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
        "8ed9fcbb8ef3c853ad0ecdc920eb8216608bd7c3b32258744e9289ec0372eb30" : {
          "name": "TestQuery",
          "source": "query TestQuery { test }"
        },
        "551253009bea9350463d15e24660e8a935abc858cd161623234fb9523b0c0717" : {
          "name": "TestMutation",
          "source": "mutation TestMutation { update { result } }"
        },
        "9b56a2829263b4d81b4eb9865470a6971c8e40e126e2ff92db51f15d0a4cb7ba" : {
          "name": "TestSubscription",
          "source": "subscription TestSubscription { watched }"
        }
      }
      """

    // when
    let rendered = subject.render(operations: operations)

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

    let expected = #"""
      {
        "9db65faebf9e503b403964a81c90edbeeb894d46029b1b42b16639dda96772bd" : {
          "name": "Friends",
          "source": "query Friends { friends { ...Name } }\\nfragment Name on Friend { name }"
        }
      }
      """#

    // when
    let rendered = subject.render(operations: operations)

    expect(rendered).to(equal(expected))
  }
}
