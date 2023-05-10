#if !COCOAPODS
import ApolloAPI
#endif

protocol GraphQLExecutionSource {
  /// The type that represents each object in data from the source.
  associatedtype RawObjectData

  associatedtype FieldCollector: FieldSelectionCollector<RawObjectData>

  /// Resolves the value for a field value for a field.
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

  func computeCacheKey(for object: RawObjectData, in schema: SchemaMetadata.Type) -> CacheKey?
}

protocol CacheKeyComputingExecutionSource: GraphQLExecutionSource {
  func opaqueObjectDataWrapper(for: RawObjectData) -> ObjectData
}

extension CacheKeyComputingExecutionSource {
  func computeCacheKey(for object: RawObjectData, in schema: SchemaMetadata.Type) -> CacheKey? {
    let dataWrapper = opaqueObjectDataWrapper(for: object)
    return schema.cacheKey(for: dataWrapper)
  }
}
