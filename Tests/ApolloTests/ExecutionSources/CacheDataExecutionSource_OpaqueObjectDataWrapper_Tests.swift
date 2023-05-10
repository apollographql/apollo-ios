import Foundation
import XCTest
import Nimble
@testable import Apollo
import ApolloAPI

#warning("TODO")
//class CacheDataExecutionSource_OpaqueObjectDataWrapper_Tests: XCTestCase {
//
//  var store: ApolloStore!
//  var transaction: ApolloStore.ReadTransaction!
//  var subject: CacheDataExecutionSource!
//
//  override func setUp() async throws {
//    try await super.setUp()
//    store = ApolloStore.mock(cache: InMemoryNormalizedCache())
//    await withCheckedContinuation { continuation in
//      store?.withinReadTransaction({
//        self.transaction = $0
//        self.subject = CacheDataExecutionSource(transaction: $0)
//        
//      }, completion: { result in
//        continuation.resume()
//      })
//    }
//  }
//
//  override func tearDown() {
//    super.tearDown()
//    subject = nil
//    transaction = nil
//    store = nil
//  }
//
//  // MARK: - Scalar Fields
//
//  func test__subscript__forScalarField_returnsValue() throws {
//    // given
//    let data = [
//      "name": "Luke Skywalker"
//    ]
//
//    let objectData = subject.opaqueObjectDataWrapper(for: data)
//
//    // when
//    let actual = objectData["name"]
//
//    // then
//    expect(actual as? String).to(equal("Luke Skywalker"))
//  }
//
//  // MARK: Object Fields
//
//  func test__subscript__forObjectField_givenObjectJSON_returnsValueAsObjectDataWrapper() throws {
//    // given
//    let data = [
//      "friend": [
//        "name": "Luke Skywalker"
//      ]
//    ]
//
//    let objectData = subject.opaqueObjectDataWrapper(for: data)
//
//    // when
//    let actual = objectData["friend"]?["name"]
//
//    // then
//    expect(actual as? String).to(equal("Luke Skywalker"))
//  }
//
//  func test__subscript__forObjectField_givenCacheReference_returnsValueAsObjectDataWrapper() throws {
//    // given
//    let friend = Record(key: "Human:1000", [
//      "__typename": "Human", "id": "1000", "name": "Han Solo"
//    ])
//    store.publish(records: RecordSet(records: [friend]))
//
//    let data = [
//      "friend": CacheReference("Human:1000")
//    ]
//
//    let objectData = subject.opaqueObjectDataWrapper(for: data)
//
//    // when
//    let actual = objectData["friend"]?["name"]
//
//    // then
//    expect(actual as? String).to(equal("Han Solo"))
//  }
//
//  // MARK: List Fields
//
//  func test__subscript__forListOfScalarField_returnsValue() throws {
//    // given
//    let data = [
//      "list": ["Luke Skywalker"]
//    ]
//
//    let objectData = subject.opaqueObjectDataWrapper(for: data)
//
//    // when
//    let actual = objectData["list"]?[0]
//
//    // then
//    expect(actual as? String).to(equal("Luke Skywalker"))
//  }
//
//  func test__subscript__forListOfObjectsField_returnsValueAsObjectDict() throws {
//    // given
//    let data = [
//      "friends": [
//        [
//          "name": "Luke Skywalker"
//        ]
//      ]
//    ]
//
//    let objectData = subject.opaqueObjectDataWrapper(for: data)
//
//    // when
//    let actual = objectData["friends"]?[0]?["name"]
//
//    // then
//    expect(actual as? String).to(equal("Luke Skywalker"))
//  }
//
//}
