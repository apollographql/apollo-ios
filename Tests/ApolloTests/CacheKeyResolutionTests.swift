import XCTest
import Nimble
import ApolloAPI
import ApolloInternalTestHelpers

class CacheKeyResolutionTests: XCTestCase {
  func test__schemaConfiguration__givenData_whenNoTypename_shouldReturnNil() {
    let object: JSONObject = [
      "id": "α"
    ]

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  // MARK: SchemaUnknownTypeCacheKeyProvider Tests

  func test__schemaConfiguration__givenData_whenUnknownType_noUnknownTypeCacheKeyProvider_shouldReturnNil() {
    let object: JSONObject = [
      "__typename": "Omega",
      "id": "ω"
    ]

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenUnknownType_withUnknownTypeCacheKeyProvider_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "Omega",
      "id": "ω"
    ]

    MockSchemaConfiguration.stub_cacheKeyProviderForUnknownType = UnknownTypeCacheKeyProvider()

    let actual: CacheReference? = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(equal(
      CacheReference("Omega:ω")
    ))
  }

  // MARK: CacheKeyProvider Tests

  func test__schemaConfiguration__givenData_whenKnownType_noCacheKeyProvider_noUnknownTypeCacheKeyProvider_shouldReturnNil() {
    class Alpha: Object { }

    let object: JSONObject = [
      "__typename": "Alpha",
      "id": "α"
    ]

    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Alpha.self }

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_withCacheKeyProvider_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "MockSchemaObject",
      "id": "β"
    ]

    MockSchemaObject.stub_cacheKeyProvider = IDCacheKeyProvider()

    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in MockSchemaObject.self }

    let actual = MockSchemaConfiguration.cacheKey(for: object)

    expect(actual).to(equal(
      CacheReference("Beta:β")
    ))
  }
//
//  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_butReturnsNilCacheKey_shouldReturnNil() {
//    struct NilCacheKeyProvider: CacheKeyProvider {
//      func cacheKey(for data: JSONObject) -> String? { nil }
//    }
//
//    class Gamma: Object {
//      static var __cacheKeyProvider: CacheKeyProvider? { NilCacheKeyProvider() }
//    }
//
//    let object: JSONObject = [
//      "__typename": "Gamma",
//      "lowercase": "γ"
//    ]
//
//    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Gamma.self }
//
//    let actual = MockSchemaConfiguration.cacheKey(for: object)
//
//    expect(actual).to(beNil())
//  }
//
//  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_withUniqueKeyGroupId_shouldReturnCacheReference() {
//    let object: JSONObject = [
//      "__typename": "Delta",
//      "lowercase": "δ"
//    ]
//
//    let actual = GreekAlphabet.cacheKey(for: object)
//
//    expect(actual).to(equal(CacheReference("TestGroup:δ")))
//  }
//
//  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_withSharedCacheKeyProvider_shouldReturnSameCacheReference() {
//    let epsilon = GreekAlphabet.cacheKey(for: [
//      "__typename": "Epsilon",
//      "lowercase": "ε"
//    ])
//
//    let zeta = GreekAlphabet.cacheKey(for: [
//      "__typename": "Zeta",
//      "lowercase": "ζ"
//    ])
//
//    expect(epsilon).to(equal(CacheReference("Epsilon:SharedCacheKeyProvider")))
//    expect(zeta).to(equal(CacheReference("Zeta:SharedCacheKeyProvider")))
//  }
}
