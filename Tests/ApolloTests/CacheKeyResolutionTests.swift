import XCTest
import Nimble
import ApolloAPI
import ApolloInternalTestHelpers

class CacheKeyResolutionTests: XCTestCase {

  func test__schemaConfiguration__givenData_whenCacheKeyInfoIsNil_shouldReturnNil() {
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = { _, _ in nil }

    let object: JSONObject = [
      "id": "α"
    ]

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenUnknownType_withCacheKeyInfoForUnknownType_shouldReturnInfoWithTypeName() {
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in nil }
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = { (_, json) in
      return try? CacheKeyInfo(jsonValue: json["id"])
    }

    let object: JSONObject = [
      "__typename": "Omega",
      "id": "ω"
    ]

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual?.key).to(equal("Omega:ω"))
  }

  func test__schemaConfiguration__givenData_whenUnknownType_nilCacheKeyInfo_shouldReturnNil() {
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in nil }
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = { (_, json) in nil }

    let object: JSONObject = [
      "__typename": "Omega",
      "id": "ω"
    ]

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_givenNilCacheKeyInfo_shouldReturnNil() {
    let Alpha = Object(typename: "Alpha", implementedInterfaces: [])

    let object: JSONObject = [
      "__typename": "Alpha",
      "id": "α"
    ]

    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Alpha }
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = { (_, json) in nil }

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_givenCacheKeyInfo_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "MockSchemaObject",
      "id": "β"
    ]

    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(equal(
      CacheReference("MockSchemaObject:β")
    ))
  }

  func test__multipleSchemaConfigurations_withDifferentCacheKeyProvidersDefinedInExtensions_shouldReturnDifferentCacheKeys() {
    let object: JSONObject = [
      "__typename": "MockSchemaObject",
      "id": "β"
    ]
  
    let actual1 = MockSchema1.cacheKey(for: object)

    expect(actual1).to(equal(
      CacheReference("MockSchemaObject:one")
    ))


    let actual2 = MockSchema2.cacheKey(for: object)

    expect(actual2).to(equal(
      CacheReference("MockSchemaObject:two")
    ))
  }

  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_withUniqueKeyGroupId_shouldReturnCacheReference() {
    let Delta = Object(typename: "Delta", implementedInterfaces: [])

    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Delta }
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = { (_, json) in
        .init(key: "δ", uniqueKeyGroupId: "GreekLetters")
    }

    let object: JSONObject = [
      "__typename": "Delta",
      "lowercase": "δ"
    ]

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(equal(CacheReference("GreekLetters:δ")))
  }

}
