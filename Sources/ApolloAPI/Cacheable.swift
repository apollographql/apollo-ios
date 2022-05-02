import Foundation
/// A type that can be the value of a `@CacheField` property. In other words, a `Cacheable` type
/// can be the value of a field on an `Object` or `Interface`
///
/// # Conforming Types:
/// - `Object`
/// - `Interface`
/// - `ScalarType` (`String`, `Int`, `Bool`, `Float`)
/// - `CustomScalarType`
/// - `GraphQLEnum` (via `CustomScalarType`)
public protocol Cacheable {
  static func value(with cacheData: JSONValue, in transaction: CacheTransaction) throws -> Self
}

extension Array: Cacheable where Element: Cacheable {

//  #warning("TODO: Unit Test")
  public static func value(
    with cacheData: JSONValue,
    in transaction: CacheTransaction
  ) throws -> Array<Element> {
    guard let dataArray = cacheData as? [JSONValue] else {
      throw CacheError.Reason.unrecognizedCacheData(cacheData, forType: Self.self)
    }

    return try dataArray.map { try Element.value(with: $0, in: transaction) }
  }

}

extension Optional: Cacheable where Wrapped: Cacheable {

//  #warning("TODO: Unit Test")
  public static func value(
    with cacheData: JSONValue,
    in transaction: CacheTransaction
  ) throws -> Self {
    if cacheData is NSNull {
      return nil
    }

    return try Wrapped.value(with: cacheData, in: transaction)
  }

}
