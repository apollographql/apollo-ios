/// Contains the information needed to resolve a ``CacheReference`` in a `NormalizedCache`.
///
/// You can create and return a ``CacheKeyInfo`` from your implementation of the
/// ``SchemaConfiguration/cacheKeyInfo(for:object:)`` function to configure the cache key
/// resolution for the types in the schema, which is used by `NormalizedCache` mechanisms.
///
/// ## Cache Key Resolution
/// You can use the ``init(jsonValue:uniqueKeyGroup:)`` convenience initializer in the
/// implementation of your ``SchemaConfiguration/cacheKeyInfo(for:object:)`` function to
/// easily resolve the cache key for an object.
///
/// For an object of the type `Dog` with a unique id represented by an `id` field, you may
/// implement cache key resolution with:
/// ```swift
/// public extension MySchema {
///   static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
///     switch type {
///     case Objects.Dog:
///       return try? CacheKeyInfo(jsonValue: object["id"])
///       default:
///       return nil
///     }
///   }
/// }
/// ```
///
/// ### Resolving Cache Keys by Interfaces
/// If you have multiple objects that conform to an ``Interface`` with the same cache id resolution
/// strategy, you can resolve the id based on the ``Interface``.
///
/// For example, for a schema with `Dog` and `Cat` ``Object`` types that implement a `Pet`
/// ``Interface``, you may implement cache key resolution with:
/// ```swift
/// public extension MySchema {
///   static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
///     if type.implements(Interfaces.Pet) {
///       return try? CacheKeyInfo(jsonValue: object["id"])
///     }
///
///     return nil
///   }
/// }
/// ```
///
/// ### Grouping Cached Objects by Interfaces
/// If your keys are guaranteed to be unique across all ``Object`` types that implement an
/// ``Interface``, you may want to group them together in the cache. See ``uniqueKeyGroup`` for
/// more information on the benefits of grouping cached objects.
/// ```swift
/// public extension MySchema {
///   static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
///     if type.implements(Interfaces.Pet) {
///       return try? CacheKeyInfo(jsonValue: object["id"], uniqueKeyGroup: Interfaces.Pet.name)
///     }
///
///     return nil
///   }
/// }
/// ```
public struct CacheKeyInfo {
  /// The unique cache id for the response object for the ``CacheKeyInfo``.
  ///
  /// > Important: The ``id`` must be deterministic and unique for all objects with the same
  /// ``Object/typename`` or ``uniqueKeyGroup``. That is, the ``id`` will be the same
  /// every time for a response object representing the same entity in the `NormalizedCache` and
  /// the same ``id`` will never be used for reponse objects representing different objects that
  /// also have the same ``Object/typename`` or ``uniqueKeyGroup``.
  public let id: String

  /// An optional identifier for a group of objects that should be grouped together in the
  /// `NormalizedCache`.
  ///
  /// By default, objects are grouped in the `NormalizedCache` by their ``Object/typename``. If
  /// multiple distinct types can be grouped together in the cache, the ``CacheKeyInfo`` for each
  /// ``Object`` should have the same ``uniqueKeyGroup``.
  ///
  /// > Tip: By grouping objects together, their resolved keys in the `NormalizedCache` will have the
  /// same prefix. This allows you to search for cached objects in the same group by their cache
  /// key.
  ///
  /// In the future ``uniqueKeyGroup``s may be used for more advanced cache optimizations
  /// and operations.
  ///
  /// > Important: All objects with the same ``uniqueKeyGroup`` must have unique `key`s across all
  /// types.
  public let uniqueKeyGroup: String?

  /// A convenience initializer for creating a ``CacheKeyInfo`` from the value of a field on a
  /// ``JSONObject`` dictionary representing a GraphQL response object.
  ///
  /// This function reads the value of the provided field, converting it to a `String` suitable
  /// for use as a cache ``id``.
  ///
  /// - Throws: A `JSONDecodingError` if the `jsonValue` provided is `nil`.
  ///
  /// - Parameters:
  ///   - jsonValue: The value of a field on a ``JSONObject`` to use as the cache ``id``.
  ///   - uniqueKeyGroup: An optional ``uniqueKeyGroup`` for the ``CacheKeyInfo``.
  ///     Defaults to `nil`.
  @inlinable public init(jsonValue: JSONValue?, uniqueKeyGroup: String? = nil) throws {
    guard let jsonValue = jsonValue else {
      throw JSONDecodingError.missingValue
    }

    self.init(id: try String(_jsonValue: jsonValue), uniqueKeyGroup: uniqueKeyGroup)
  }

  /// The Designated Initializer
  ///
  /// - Parameters:
  ///   - id: The unique cache key for the response object for the ``CacheKeyInfo``.
  ///   - uniqueKeyGroup: An optional identifier for a group of objects that should be grouped
  ///     together in the `NormalizedCache`.
  @inlinable public init(id: String, uniqueKeyGroup: String? = nil) {
    self.id = id
    self.uniqueKeyGroup = uniqueKeyGroup
  }
}
