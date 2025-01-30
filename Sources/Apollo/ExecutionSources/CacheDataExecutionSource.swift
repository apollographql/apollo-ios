#if !COCOAPODS
import ApolloAPI
#endif

/// A `GraphQLExecutionSource` configured to execute upon the data stored in a ``NormalizedCache``.
///
/// Each object exposed by the cache is represented as a `Record`.
struct CacheDataExecutionSource: GraphQLExecutionSource {
  typealias RawObjectData = Record
  typealias FieldCollector = CacheDataFieldSelectionCollector

  /// A `weak` reference to the transaction the cache data is being read from during execution.
  /// This transaction is used to resolve references to other objects in the cache during field
  /// value resolution.
  ///
  /// This property is `weak` to ensure there is not a retain cycle between the transaction and the
  /// execution pipeline. If the transaction has been deallocated, execution cannot continue
  /// against the cache data.
  weak var transaction: ApolloStore.ReadTransaction?

  /// Used to determine whether deferred selections within a selection set should be executed at the same
  /// time as the other selections.
  ///
  /// When executing on cache data all selections, including deferred, must be executed together because
  /// there is only a single response from the cache data. Any deferred selection that was cached will
  /// be returned in the response.
  var shouldAttemptDeferredFragmentExecution: Bool { true }

  init(transaction: ApolloStore.ReadTransaction) {
    self.transaction = transaction
  }

  func resolveField(
    with info: FieldExecutionInfo,
    on object: Record
  ) -> PossiblyDeferred<JSONValue?> {
    PossiblyDeferred {
      let value = try object[info.cacheKeyForField()]

      switch value {
      case let reference as CacheReference:
        return deferredResolve(reference: reference).map { $0 as JSONValue }

      case let referenceList as [JSONValue]:
        return referenceList
          .enumerated()
          .deferredFlatMap { index, element in
            guard let cacheReference = element as? CacheReference else {
              return .immediate(.success(element))
            }

            return self.deferredResolve(reference: cacheReference)
              .mapError { error in
                if !(error is GraphQLExecutionError) {
                  return GraphQLExecutionError(
                    path: info.responsePath.appending(String(index)),
                    underlying: error
                  )
                } else {
                  return error
                }
              }.map { $0 as JSONValue }
          }.map { $0 as JSONValue }

      default:
        return .immediate(.success(value))
      }
    }
  }

  private func deferredResolve(reference: CacheReference) -> PossiblyDeferred<Record> {
    guard let transaction else {
      return .immediate(.failure(ApolloStore.Error.notWithinReadTransaction))
    }

    return transaction.loadObject(forKey: reference.key)
  }

  func computeCacheKey(
    for object: Record,
    in schema: any SchemaMetadata.Type,
    inferredToImplementInterface interface: Interface?
  ) -> CacheKey? {
    return object.key
  }

  /// A wrapper around the `DefaultFieldSelectionCollector` that maps the `Record` object to it's
  /// `fields` representing the object's data.
  struct CacheDataFieldSelectionCollector: FieldSelectionCollector {
    static func collectFields(
      from selections: [Selection],
      into groupedFields: inout FieldSelectionGrouping,
      for object: Record,
      info: ObjectExecutionInfo
    ) throws {
      return try DefaultFieldSelectionCollector.collectFields(
        from: selections,
        into: &groupedFields,
        for: object.fields,
        info: info
      )
    }
  }
}


