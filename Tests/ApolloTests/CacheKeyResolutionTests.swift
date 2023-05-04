import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class CacheKeyResolutionTests: XCTestCase {

  func test__schemaConfiguration__givenData_whenCacheKeyInfoIsNil_shouldReturnNil() {
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = { _, _ in nil }

    let object: JSONObject = [
      "id": "α"
    ]

    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual = MockSchemaMetadata.cacheKey(for: objectDict)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenUnknownType_withCacheKeyInfoForUnknownType_shouldReturnInfoWithTypeName() {
    MockSchemaMetadata.stub_objectTypeForTypeName = { _ in nil }
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = { (_, json) in
      return try? CacheKeyInfo(jsonValue: json["id"])
    }

    let object: JSONObject = [
      "__typename": "Omega",
      "id": "ω"
    ]

    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual = MockSchemaMetadata.cacheKey(for: objectDict)

    expect(actual?.key).to(equal("Omega:ω"))
  }

  func test__schemaConfiguration__givenData_whenUnknownType_nilCacheKeyInfo_shouldReturnNil() {
    MockSchemaMetadata.stub_objectTypeForTypeName = { _ in nil }
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = { (_, json) in nil }

    let object: JSONObject = [
      "__typename": "Omega",
      "id": "ω"
    ]

    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual = MockSchemaMetadata.cacheKey(for: objectDict)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_givenNilCacheKeyInfo_shouldReturnNil() {
    let Alpha = Object(typename: "Alpha", implementedInterfaces: [])

    let object: JSONObject = [
      "__typename": "Alpha",
      "id": "α"
    ]

    MockSchemaMetadata.stub_objectTypeForTypeName = { _ in Alpha }
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = { (_, json) in nil }

    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual = MockSchemaMetadata.cacheKey(for: objectDict)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_givenCacheKeyInfo_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "MockSchemaObject",
      "id": "β"
    ]

    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual = MockSchemaMetadata.cacheKey(for: objectDict)

    expect(actual).to(equal(
      CacheReference("MockSchemaObject:β")
    ))
  }

  func test__multipleSchemaConfigurations_withDifferentCacheKeyProvidersDefinedInExtensions_shouldReturnDifferentCacheKeys() {
    let object: JSONObject = [
      "__typename": "MockSchemaObject",
      "id": "β"
    ]
  
    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual1 = MockSchema1.cacheKey(for: objectDict)

    expect(actual1).to(equal(
      CacheReference("MockSchemaObject:one")
    ))

    let actual2 = MockSchema2.cacheKey(for: objectDict)

    expect(actual2).to(equal(
      CacheReference("MockSchemaObject:two")
    ))
  }

  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_withUniqueKeyGroupId_shouldReturnCacheReference() {
    let Delta = Object(typename: "Delta", implementedInterfaces: [])

    MockSchemaMetadata.stub_objectTypeForTypeName = { _ in Delta }
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = { (_, json) in
        .init(id: "δ", uniqueKeyGroup: "GreekLetters")
    }

    let object: JSONObject = [
      "__typename": "Delta",
      "lowercase": "δ"
    ]

    let objectDict = NetworkResponseExecutionSource().opaqueObjectDataWrapper(for: object)
    let actual = MockSchemaMetadata.cacheKey(for: objectDict)

    expect(actual).to(equal(CacheReference("GreekLetters:δ")))
  }

}
