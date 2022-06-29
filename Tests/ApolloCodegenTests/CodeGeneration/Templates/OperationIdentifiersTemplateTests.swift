import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils
import ApolloCodegenInternalTestHelpers

class OperationIdentifiersTemplateTests: XCTestCase {
  var subject: OperationIdentifiersTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Render tests

  func test__render__givenSingleOperation_shouldOutputJSONFormat() throws {
    // given
    let operations: [OperationIdentifier] = [
      OperationIdentifier(
        hash: "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad",
        name: "TestQuery",
        source: """
        query TestQuery {
          test
        }
        """
      )
    ]

    let expected = """
      {
        "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad": {
          "name": "TestQuery",
          "source": "query TestQuery {\\n  test\\n}"
        }
      }
      """

    subject = OperationIdentifiersTemplate(operationIdentifiers: operations)

    // when
    let rendered = subject.render()

    expect(rendered).to(equal(expected))
  }

  func test__render__givenMultipleOperations_shouldOutputJSONFormat() throws {
    // given
    let operations: [OperationIdentifier] = [
      OperationIdentifier(
        hash: "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad",
        name: "TestQuery",
        source: """
        query TestQuery {
          test
        }
        """
      ),
      OperationIdentifier(
        hash: "50ed8cda22910b3b708bc69402626f9fe4f1bbaeafb40df9084d029fade5bab1",
        name: "TestMutation",
        source: """
        mutation TestMutation {
          update {
            result
          }
        }
        """
      ),
      OperationIdentifier(
        hash: "55f75259c34f0ccc6b131d23545d9fa79885c93ec785176bd9b6d3c4062fcaed",
        name: "TestSubscription",
        source: """
        subscription TestSubscription {
          watched
        }
        """
      )
    ]

    let expected = """
      {
        "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad": {
          "name": "TestQuery",
          "source": "query TestQuery {\\n  test\\n}"
        },
        "50ed8cda22910b3b708bc69402626f9fe4f1bbaeafb40df9084d029fade5bab1": {
          "name": "TestMutation",
          "source": "mutation TestMutation {\\n  update {\\n    result\\n  }\\n}"
        },
        "55f75259c34f0ccc6b131d23545d9fa79885c93ec785176bd9b6d3c4062fcaed": {
          "name": "TestSubscription",
          "source": "subscription TestSubscription {\\n  watched\\n}"
        }
      }
      """

    subject = OperationIdentifiersTemplate(operationIdentifiers: operations)

    // when
    let rendered = subject.render()

    expect(rendered).to(equal(expected))
  }

  func test__render__givenOperationSourceNeedsEscapedCharacters_shouldOutputValidJSON() throws {
    // given
    let operations: [OperationIdentifier] = [
      OperationIdentifier(
        hash: "4a1250de93ebcb5cad5870acf15001112bf27bb963e8709555b5ff67a1405374",
        name: "CreateAwesomeReview",
        source: "mutation CreateAwesomeReview {\n  createReview(episode: JEDI, review: {stars: 10, commentary: \"This is awesome! \\o/ \"}) {\n    __typename\n    stars\n    commentary\n  }\n}"
      )
    ]

    let expected = """
      {
        "4a1250de93ebcb5cad5870acf15001112bf27bb963e8709555b5ff67a1405374": {
          "name": "CreateAwesomeReview",
          "source": "mutation CreateAwesomeReview {\\n  createReview(episode: JEDI, review: {stars: 10, commentary: \\"This is awesome! \\o/ \\"}) {\\n    __typename\\n    stars\\n    commentary\\n  }\\n}"
        }
      }
      """

    subject = OperationIdentifiersTemplate(operationIdentifiers: operations)

    // when
    let rendered = subject.render()

    expect(rendered).to(equal(expected))
  }
}
