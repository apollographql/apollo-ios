import XCTest
import Nimble
import ApolloAPI

/// Test objects
fileprivate class Alpha : Object { }
fileprivate class Beta : Object { }
fileprivate class Gamma : Object { }
fileprivate class Delta : Object { }
fileprivate class Epsilon : Object { }
fileprivate class Zeta : Object { }

/// CacheKeyProvider extension - returns a valid string.
extension Beta: CacheKeyProvider {
  static func cacheKey(for data: JSONObject) -> String? {
    "Implementation-of-CacheKeyProvider"
  }
}

/// CacheKeyProvider extension - returns nil key.
extension Gamma: CacheKeyProvider {
  static func cacheKey(for data: JSONObject) -> String? {
    nil
  }
}

/// CacheKeyProvider extension - with grouping.
extension Delta: CacheKeyProvider {
  static var uniqueKeyGroupId: StaticString? {
    return "TestGroup"
  }

  static func cacheKey(for data: JSONObject) -> String? {
    return data["lowercase"] as? String
  }
}

/// Schema configuration for test objects
fileprivate enum GreekAlphabet: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Alpha": return Alpha.self
    case "Beta": return Beta.self
    case "Gamma": return Gamma.self
    case "Delta": return Delta.self
    default: return nil
    }
  }
}

/// Schema configuration, no test objects. Implements SchemaUnknownTypeCacheKeyProvider, returning
/// a valid string.
fileprivate enum SchemaAsCacheKeyProvider: SchemaConfiguration, SchemaUnknownTypeCacheKeyProvider, CacheKeyProvider {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    return nil
  }

  public static func cacheKeyProviderForUnknownType(
    withTypename: String, data: JSONObject
  ) -> CacheKeyProvider.Type? {
    self
  }

  public static func cacheKey(for data: JSONObject) -> String? {
    "Implementation-of-SchemaUnknownTypeCacheKeyProvider"
  }
}

// MARK: -

class SchemaConfigurationTests: XCTestCase {

  func test__schemaConfiguration__givenData_whenNoTypename_shouldReturnNil() {
    let object: JSONObject = [
      "lowercase": "α"
    ]

    let actual = GreekAlphabet.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  // MARK: SchemaUnknownTypeCacheKeyProvider Tests

  func test__schemaConfiguration__givenData_whenUnknownType_noUnknownTypeCacheKeyProvider_shouldReturnNil() {
    let object: JSONObject = [
      "__typename": "Omega",
      "lowercase": "ω"
    ]

    let actual = GreekAlphabet.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenUnknownType_withUnknownTypeCacheKeyProvider_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "Omega",
      "lowercase": "ω"
    ]

    let actual: CacheReference? = SchemaAsCacheKeyProvider.cacheKey(for: object)

    expect(actual).to(equal(
      CacheReference("Omega:Implementation-of-SchemaUnknownTypeCacheKeyProvider")
    ))
  }

  // MARK: CacheKeyProvider Tests
  
  func test__schemaConfiguration__givenData_whenKnownType_isNotCacheKeyProvider_noUnknownTypeCacheKeyProvider_shouldReturnNil() {
    let object: JSONObject = [
      "__typename": "Alpha",
      "lowercase": "α"
    ]

    let actual = GreekAlphabet.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "Beta",
      "lowercase": "β"
    ]

    let actual = GreekAlphabet.cacheKey(for: object)

    expect(actual).to(equal(
      CacheReference("Beta:Implementation-of-CacheKeyProvider")
    ))
  }

  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_butReturnsNilCacheKey_shouldReturnNil() {
    let object: JSONObject = [
      "__typename": "Gamma",
      "lowercase": "γ"
    ]

    let actual = GreekAlphabet.cacheKey(for: object)

    expect(actual).to(beNil())
  }

  func test__schemaConfiguration__givenData_whenKnownType_isCacheKeyProvider_withUniqueKeyGroupId_shouldReturnCacheReference() {
    let object: JSONObject = [
      "__typename": "Delta",
      "lowercase": "δ"
    ]

    let actual = GreekAlphabet.cacheKey(for: object)

    expect(actual).to(equal(CacheReference("TestGroup:δ")))
  }

}
