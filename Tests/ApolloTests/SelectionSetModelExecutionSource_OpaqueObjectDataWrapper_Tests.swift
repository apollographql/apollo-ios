import Foundation
import XCTest
import Nimble
@testable import Apollo
import ApolloAPI

class SelectionSetModelExecutionSource_OpaqueObjectDataWrapper_Tests: XCTestCase {

  // MARK: - Helpers

  func test__subscript__forScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "name": "Luke Skywalker"
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["name"]

    // then
    expect(actual is String).to(beTrue())
    expect(actual).to(equal("Luke Skywalker"))
  }

  func test__subscript__forCustomScalarField_returnsValueAsJSONValue() throws {
    // given
    let data = DataDict(
      data: [
        "customScalar": MockCustomScalar<String>(value: "Luke Skywalker")
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["customScalar"]

    // then
    expect(actual is String).to(beTrue())
    expect(actual).to(equal("Luke Skywalker"))
  }

}
