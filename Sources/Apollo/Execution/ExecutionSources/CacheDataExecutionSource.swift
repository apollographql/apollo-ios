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
        return resolveReferences(in: referenceList, info: info).map { $0 as JSONValue? }

      default:
        return .immediate(.success(value))
      }
    }
  }
  
  private func resolveCacheKey(
    with info: FieldExecutionInfo,
    on object: Record
  ) throws -> JSONValue? {
    let key = try info.cacheKeyForField()
    if let storedValue = object[key] {
      return storedValue
    }

    return resolveFieldPolicyValue(with: info)
  }

  /// Field policies resolve a single key to an object field, or a list of keys to a flat list field,
  /// when the field has no value stored on the parent record for its arguments. Fields returning
  /// nested lists, and policy results that don't match the shape of the field's type, have no
  /// field policy value.
  private func resolveFieldPolicyValue(with info: FieldExecutionInfo) -> JSONValue? {
    let depth = listDepth(of: info.field.type)

    guard depth <= 1,
          let returnTypename = typename(for: info.field),
          let fieldPolicyResult = resolveProgrammaticFieldPolicy(with: info, listDepth: depth) ??
            FieldPolicyDirectiveEvaluator(field: info.field, variables: info.parentInfo.variables)?.resolveFieldPolicy()
    else {
      return nil
    }

    switch (fieldPolicyResult, depth) {
    case (.single(let key), 0):
      return CacheReference(formatCacheKey(withInfo: key, andTypename: returnTypename))

    case (.list(let keys), 1):
      return keys.map {
        CacheReference(formatCacheKey(withInfo: $0, andTypename: returnTypename))
      } as [JSONValue] as JSONValue

    default:
      return nil
    }
  }

  private func resolveProgrammaticFieldPolicy(
    with info: FieldExecutionInfo,
    listDepth: Int
  ) -> FieldPolicyResult? {
    guard let provider = info.parentInfo.schema.configuration.self as? (any FieldPolicy.Provider.Type),
          let arguments = info.field.arguments else {
      return nil
    }

    let field = FieldPolicy.Field(info.field)
    let inputData = FieldPolicy.InputData(_rawType: .inputValue(arguments), _variables: info.parentInfo.variables)

    switch listDepth {
    case 0:
      return provider.cacheKey(for: field, inputData: inputData, path: info.responsePath).map { .single($0) }
    case 1:
      return provider.cacheKeyList(for: field, inputData: inputData, path: info.responsePath).map { .list($0) }
    default:
      return nil
    }
  }
  
  private func formatCacheKey(
    withInfo info: CacheKeyInfo,
    andTypename typename: String
  ) -> String {
    return "\(info.uniqueKeyGroup ?? typename):\(info.id)"
  }
  
  private func listDepth(of type: Selection.Field.OutputType) -> Int {
    switch type {
    case .nonNull(let innerType): return listDepth(of: innerType)
    case .list(let elementType): return 1 + listDepth(of: elementType)
    default: return 0
    }
  }

  private func typename(for field: Selection.Field) -> String? {
    switch field.type.namedType {
    case .object(let selectionSetType):
      return selectionSetType.__parentType.__typename
    default:
      return nil
    }
  }

  private func resolveReferences(
    in list: [JSONValue],
    info: FieldExecutionInfo
  ) -> PossiblyDeferred<JSONValue> {
    return list
      .enumerated()
      .deferredFlatMap { index, element in
        if let cacheReference = element as? CacheReference {
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
        } else if let nestedList = element as? [JSONValue] {
          return self.resolveReferences(in: nestedList, info: info)
        } else {
          return .immediate(.success(element))
        }
      }.map { $0 as JSONValue }
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
