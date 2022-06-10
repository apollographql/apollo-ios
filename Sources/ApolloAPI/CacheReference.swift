/// Represents a reference to a record for a GraphQL Object in the cache.
public struct CacheReference: Hashable {

  /// A CacheReference referencing the root query object.
  public static let RootQuery: CacheReference = CacheReference("QUERY_ROOT")
  /// A CacheReference referencing the root mutation object.
  public static let RootMutation: CacheReference = CacheReference("MUTATION_ROOT")
  /// A CacheReference referencing the root subscription object.
  public static let RootSubscription: CacheReference = CacheReference("SUBSCRIPTION_ROOT")

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
  /// The key for an object must be:
  ///   - Unique across the type
  ///     - No two different objects with the same "__typename" can have the same key.
  ///     - Keys do not need to be unique from keys for different types (objects with
  ///      different "__typename"s).
  ///   - Stable
  ///     - The key for an object may not ever change. If the cache recieves a new key, it will
  ///     treat the object as an entirely new object. There is no mechanisim for cache normalization
  ///     in which an object changes its key but maintains its identity.
  ///
  /// Any format for keys will work, as long as they are stable and unique.
  /// If multiple fields must be used to derive a unique key, we recommend joining the values for
  /// the fields with a ":" delimiter. For example, if you need to join the title of a book and the
  /// author name to use as a unique key, you could return "Iliad:Homer".
  ///
  /// A reference to a record that does not have it's own unique cache key is based on a path from
  /// another cache reference or a root object.
  public let key: String

  /// Initializer
  ///
  /// - Parameters:
  ///   - key: The unique identifier for the referenced object.
  public init(_ key: String) {
    self.key = key
  }

}

extension CacheReference: CustomStringConvertible {
  public var description: String {
    return "-> #\(key)"
  }
}
