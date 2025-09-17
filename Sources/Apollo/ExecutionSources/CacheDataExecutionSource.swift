@_spi(Execution) import ApolloAPI

/// A `GraphQLExecutionSource` configured to execute upon the data stored in a ``NormalizedCache``.
///
/// Each object exposed by the cache is represented as a ``Record``.
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
      
      let value = try resolveCacheKey(with: info, on: object)

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
  
  private func resolveCacheKey(
    with info: FieldExecutionInfo,
    on object: Record
  ) throws -> JSONValue? {
    if let fieldPolicyResult = resolveProgrammaticFieldPolicy(with: info, and: info.field.type) ??
        FieldPolicyDirectiveEvaluator(field: info.field, variables: info.parentInfo.variables)?.resolveFieldPolicy(),
       let returnTypename = typename(for: info.field) {
      
      switch fieldPolicyResult {
      case .single(let key):
        return object[formatCacheKey(withInfo: key, andTypename: returnTypename)]
      case .list(let keys):
        var keyList: [JSONValue] = []
        for key in keys {
          if let cacheKey = object[formatCacheKey(withInfo: key, andTypename: returnTypename)] {
            keyList.append(cacheKey)
          }
        }
        return keyList as JSONValue
      }
    }
    
    let key = try info.cacheKeyForField()
    return object[key]
  }
  
  private func resolveProgrammaticFieldPolicy(
    with info: FieldExecutionInfo,
    and type: Selection.Field.OutputType
  ) -> FieldPolicyResult? {
    guard let provider = info.parentInfo.schema.configuration.self as? (any FieldPolicyProvider.Type) else {
      return nil
    }
    
    switch type {
    case .nonNull(let innerType):
      return resolveProgrammaticFieldPolicy(with: info, and: innerType)
    case .list(_):
      if let keys = provider.cacheKeyList(
        for: info.field,
        variables: info.parentInfo.variables,
        path: info.responsePath
      ) {
        return .list(keys)
      }
    default:
      if let key = provider.cacheKey(
        for: info.field,
        variables: info.parentInfo.variables,
        path: info.responsePath
      ) {
        return .single(key)
      }
    }
    return nil
  }
  
  private func formatCacheKey(
    withInfo info: CacheKeyInfo,
    andTypename typename: String
  ) -> String {
    return "\(info.uniqueKeyGroup ?? typename):\(info.id)"
  }
  
  private func typename(for field: Selection.Field) -> String? {
    switch field.type.namedType {
    case .object(let selectionSetType):
      return selectionSetType.__parentType.__typename
    default:
      return nil
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
