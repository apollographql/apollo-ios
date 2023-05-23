import Foundation
import XCTest
import Nimble
@testable import Apollo
import ApolloAPI

class NetworkResponseExecutionSource_OpaqueObjectDataWrapper_Tests: XCTestCase {

  var subject: NetworkResponseExecutionSource!

  override func setUp() {
    super.setUp()
    subject = NetworkResponseExecutionSource()
  }

  override func tearDown() {
    super.tearDown()
    subject = nil
  }

  // MARK: - Scalar Fields

  func test__subscript__forStringScalarField_returnsValue() throws {
    // given
    let data = [
      "name": "Luke Skywalker"
    ]

    let objectData = subject.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["name"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }
  
  func test__subscript_forIntScalarField_returnsValue() throws {
    // given
    let data = [
      "value": Int(10)
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    let actual = objectData["value"]
    
    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript_forInt32ScalarField_returnsValue() throws {
    // given
    let data = [
      "value": Int32(10)
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    let actual = objectData["value"]
    
    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript_forInt64ScalarField_returnsValue() throws {
    // given
    let data = [
      "value": Int64(10)
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    let actual = objectData["value"]
    
    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript_forBoolScalarField_returnsScalarTypeValue() throws {
    // given
    let data = [
      "value": true
    ]

    let objectData = subject.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["value"]

    // then
    expect(actual as? Bool).to(equal(true))
  }
  
  func test__subscript_forDoubleScalarField_returnsScalarTypeValue() throws {
    // given
    let data = [
      "value": Double(10.5)
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    let actual = objectData["value"]
    
    // then
    expect(actual as? Double).to(equal(10.5))
  }
  
  func test__subscript_forFloatScalarField_returnsScalarTypeValue() throws {
    // given
    let data = [
      "value": Float(10.5)
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    let actual = objectData["value"]
    
    // then
    expect(actual as? Float).to(equal(10.5))
  }

  // MARK: Object Fields

  func test__subscript__forObjectField_givenObjectJSON_returnsValueAsObjectDataWrapper() throws {
    // given
    let data = [
      "friend": [
        "name": "Luke Skywalker"
      ]
    ]

    let objectData = subject.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["friend"]?["name"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }
  
  // MARK: List Fields

  func test__subscript__forListOfScalarField_returnsValue() throws {
    // given
    let data = [
      "list": ["Luke Skywalker"]
    ]

    let objectData = subject.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["list"]?[0]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }

  func test__subscript__forListOfObjectsField_returnsValueAsObjectDict() throws {
    // given
    let data = [
      "friends": [
        [
          "name": "Luke Skywalker"
        ]
      ]
    ]

    let objectData = subject.opaqueObjectDataWrapper(for: data)

    // when
    let actual = objectData["friends"]?[0]?["name"]

    // then
    expect(actual as? String).to(equal("Luke Skywalker"))
  }
  
  func test__subscript__forListOfIntFields_returnsValue() throws {
    // given
    let data = [
      "values": [Int(10), Int(20)]
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    
    let actual = objectData["values"]?[0]
    
    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forListOfInt32Fields_returnsValue() throws {
    // given
    let data = [
      "values": [Int32(10), Int32(20)]
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    
    let actual = objectData["values"]?[0]
    
    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forListOfInt64Fields_returnsValue() throws {
    // given
    let data = [
      "values": [Int64(10), Int64(20)]
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    
    let actual = objectData["values"]?[0]
    
    // then
    expect(actual as? Int).to(equal(10))
  }
  
  func test__subscript__forListOfBoolFields_returnsValue() throws {
    // given
    let data = [
      "values": [true, false]
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    
    let actual = objectData["values"]?[0]
    
    // then
    expect(actual as? Bool).to(equal(true))
  }
  
  func test__subscript__forListOfDoubleFields_returnsValue() throws {
    // given
    let data = [
      "values": [Double(10.5), Double(20.5)]
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    
    let actual = objectData["values"]?[0]
    
    // then
    expect(actual as? Double).to(equal(10.5))
  }
  
  func test__subscript__forListOfFloatFields_returnsValue() throws {
    // given
    let data = [
      "values": [Float(10.5), Float(20.5)]
    ]
    
    let objectData = subject.opaqueObjectDataWrapper(for: data)
    
    // when
    
    let actual = objectData["values"]?[0]
    
    // then
    expect(actual as? Float).to(equal(10.5))
  }

}
