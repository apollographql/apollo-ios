/// Represents a reference to a record for a GraphQL object in the cache.
///
/// ``CacheReference`` is just a wrapper around a `String`. But when the value for a key in a cache
/// `Record` is a `String`, we treat the string as the value. When the value for the key is a
/// ``CacheReference``, the reference's ``key`` is the cache key for another referenced object
/// that is the value.
public struct CacheReference: Sendable, Hashable {

  /// A CacheReference referencing the root query object.
  public static let RootQuery: CacheReference = CacheReference("QUERY_ROOT")

  /// A CacheReference referencing the root mutation object.
  public static let RootMutation: CacheReference = CacheReference("MUTATION_ROOT")

  /// A CacheReference referencing the root subscription object.
  public static let RootSubscription: CacheReference = CacheReference("SUBSCRIPTION_ROOT")

  /// Helper function that returns the cache's root ``CacheReference`` for the given
  /// ``GraphQLOperationType``.
  ///
  /// The Apollo `NormalizedCache` stores all objects that are not normalized
  /// (ie. don't have a unique cache key provided by the ``SchemaConfiguration``)
  /// with a ``CacheReference`` computed as the field path to the object from
  /// the root of the parent operation type.
  ///
  /// For example, given the operation:
  /// ```graphql
  /// query {
  ///   animals {
  ///     owner {
  ///       name
  ///     }
  ///   }
  /// }
  /// ```
  /// The ``CacheReference`` for the `owner` object of the third animal in the `animals` list would
  /// have a ``CacheReference/key`` of `"QUERY_ROOT.animals.2.owner`.
  ///
  /// - Parameter operationType: A ``GraphQLOperationType``
  /// - Returns: The cache's root ``CacheReference`` for the given ``GraphQLOperationType``
  public static func rootCacheReference(
    for operationType: GraphQLOperationType
  ) -> CacheReference {
    switch operationType {
    case .query:
      return RootQuery
    case .mutation:
      return RootMutation
    case .subscription:
      return RootSubscription
    }
  }

  /// The unique identifier for the referenced object.
  ///
  /// # See Also
  /// ``CacheKeyInfo``
  public let key: String

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - key: The unique identifier for the referenced object.
  public init(_ key: String) {
    self.key = key
  }

}

extension CacheReference: CustomStringConvertible {
  @inlinable public var description: String {
    return "-> #\(key)"
  }
}
