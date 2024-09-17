#if !COCOAPODS
import ApolloAPI
#endif

/// A protocol representing a data source for GraphQL data to be executed upon by a
/// `GraphQLExecutor`.
///
/// Based on the source of execution data, the way we handle portions of the execution pipeline will
/// be different. Each implementation of this protocol provides the necessary implementations for
/// executing upon data from a specific source.
@_spi(Execution)
public protocol GraphQLExecutionSource {
  /// The type that represents each object in data from the source.
  associatedtype RawObjectData

  /// The type of `FieldSelectionCollector` used for the selection grouping step of
  /// GraphQL execution.
  associatedtype FieldCollector: FieldSelectionCollector<RawObjectData>

  /// Used to determine whether deferred selections within a selection set should be executed at the same
  /// time as the other selections.
  var shouldAttemptDeferredFragmentExecution: Bool { get }

  /// Resolves the value for given field on a data object from the source.
  ///
  ///  Because data may be loaded from a database, these loads are batched for performance reasons.
  ///  By returning a `PossiblyDeferred` wrapper, we allow `ApolloStore` to use a `DataLoader` that
  ///  will defer loading the next batch of records from the cache until they are needed.
  ///
  /// - Returns: The value for the field represented by the `info` on the `object`.
  ///  For a field with a scalar value, this should be a raw JSON value.
  ///  For fields whose type is an object, this should be of the source's `ObjectData` type or
  ///  a `CacheReference` that can be resolved by the source.
  func resolveField(
    with info: FieldExecutionInfo,
    on object: RawObjectData
  ) -> PossiblyDeferred<AnyHashable?>

  /// Returns the cache key for an object to be used during GraphQL execution.
  /// - Parameters:
  ///   - object: The data for the object from the source.
  ///   - schema: The schema that the type the object data represents belongs to.
  /// - Returns: A cache key for normalizing the object in the cache. If `nil` is returned the
  /// object is assumed to be stored in the cache with no normalization. The executor will
  /// construct a cache key based on the object's path in its enclosing operation.
  func computeCacheKey(for object: RawObjectData, in schema: any SchemaMetadata.Type) -> CacheKey?
}

/// A type of `GraphQLExecutionSource` that uses the user defined cache key computation
/// defined in the ``SchemaConfiguration``.
@_spi(Execution)
public protocol CacheKeyComputingExecutionSource: GraphQLExecutionSource {
  /// A function that should return an `ObjectData` wrapper that performs and custom
  /// transformations required to transform the raw object data from the source into a consistent
  /// format to be exposed to the user's ``SchemaConfiguration/cacheKeyInfo(for:object:)`` function.
  func opaqueObjectDataWrapper(for: RawObjectData) -> ObjectData
}

extension CacheKeyComputingExecutionSource {
  @_spi(Execution) public func computeCacheKey(for object: RawObjectData, in schema: any SchemaMetadata.Type) -> CacheKey? {
    let dataWrapper = opaqueObjectDataWrapper(for: object)
    return schema.cacheKey(for: dataWrapper)
  }
}
