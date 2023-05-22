import Foundation
import XCTest
import Nimble
@testable import Apollo
import ApolloAPI

class SelectionSetModelExecutionSource_OpaqueObjectDataWrapper_Tests: XCTestCase {

  // MARK: - Scalar Fields

  func test__subscript__forStringScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "name": "Luke Skywalker"
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["name"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }
  
  func test__subscript__forIntScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "value": Int(10)
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forInt32ScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "value": Int32(10)
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forInt64ScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "value": Int64(10)
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forBoolScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "value": true
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Bool).to(equal(true))
  }
  
  func test__subscript__forDoubleScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "value": Double(10.5)
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Double).to(equal(10.5))
  }
  
  func test__subscript__forFloatScalarField_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "value": Float(10.5)
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Float).to(equal(10.5))
  }

  func test__subscript__forCustomScalarField_returnsValueAsJSONValue() throws {
    // given
    let data = DataDict(
      data: [
        "customScalar": MockCustomScalar<String>(value: "Luke Skywalker")
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["customScalar"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }

  // MARK: Object Fields

  func test__subscript__forObjectField_returnsValueAsObjectDataWrapper() throws {
    // given
    let data = DataDict(
      data: [
        "friend": DataDict(
          data: [
            "name": "Luke Skywalker"
          ],
          fulfilledFragments: []
        )
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["friend"]?["name"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }

  // MARK: List Fields

  func test__subscript__forListOfStringScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "list": ["Luke Skywalker"]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["list"]?[0]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }
  
  func test__subscript__forListOfIntScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "values": [Int(10), Int(20)]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["values"]?[0]

    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forListOfInt32ScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "values": [Int32(10), Int32(20)]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["values"]?[0]

    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forListOfInt64ScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "values": [Int64(10), Int64(20)]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["values"]?[0]

    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forListOfBoolScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "values": [true, false]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["values"]?[0]

    // then
    expect(actual as? Bool).to(equal(true))
  }
  
  func test__subscript__forListOfDoubleScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "values": [Double(10.5), Double(20.5)]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["values"]?[0]

    // then
    expect(actual as? Double).to(equal(10.5))
  }
  
  func test__subscript__forListOfFloatScalarFields_returnsValue() throws {
    // given
    let data = DataDict(
      data: [
        "values": [Float(10.5), Float(20.5)]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["values"]?[0]

    // then
    expect(actual as? Float).to(equal(10.5))
  }

  func test__subscript__forListOfCustomScalarField_returnsValueAsListOfJSONValue() throws {
    // given
    let data = DataDict(
      data: [
        "list": [MockCustomScalar<String>(value: "Luke Skywalker")]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["list"]?[0]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }

  func test__subscript__forListOfObjectsField_returnsValueAsObjectDict() throws {
    // given
    let data = DataDict(
      data: [
        "friends": [
          DataDict(
            data: [
              "name": "Luke Skywalker"
            ],
            fulfilledFragments: []
          )
        ]
      ],
      fulfilledFragments: []
    )

    let objectData = SelectionSetModelExecutionSource().opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["friends"]?[0]?["name"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }

}
