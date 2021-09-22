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
