import Foundation
#if !COCOAPODS
@_spi(Internal) import ApolloAPI
#endif

@_spi(Execution)
public class ObjectExecutionInfo {
  let rootType: any SelectionSet.Type
  let variables: GraphQLOperation.Variables?
  let schema: any SchemaMetadata.Type
  private(set) var responsePath: ResponsePath = []
  private(set) var cachePath: ResponsePath = []
  fileprivate(set) var fulfilledFragments: Set<ObjectIdentifier>
  fileprivate(set) var deferredFragments: Set<ObjectIdentifier> = []

  fileprivate init(
    rootType: any SelectionSet.Type,
    variables: GraphQLOperation.Variables?,
    schema: (any SchemaMetadata.Type),
    responsePath: ResponsePath,
    cachePath: ResponsePath
  ) {
    self.rootType = rootType
    self.variables = variables
    self.schema = schema
    self.responsePath = responsePath
    self.cachePath = cachePath
    self.fulfilledFragments = [ObjectIdentifier(rootType)]
  }

  fileprivate init(
    rootType: any SelectionSet.Type,
    variables: GraphQLOperation.Variables?,
    schema: (any SchemaMetadata.Type),
    withRootCacheReference root: CacheReference? = nil
  ) {
    self.rootType = rootType
    self.variables = variables
    self.schema = schema
    if let root = root {
      cachePath = [root.key]
    }
    self.fulfilledFragments = [ObjectIdentifier(rootType)]
  }

  func runtimeObjectType(
    for json: JSONObject
  ) -> Object? {
    guard let __typename = json["__typename"] as? String else {
      guard let objectType = rootType.__parentType as? Object else {
        return nil
      }
      return schema.objectType(forTypename: objectType.typename)
    }
    return schema.objectType(forTypename: __typename)
  }
}

/// Stores the information for executing a field and all duplicate fields on the same selection set.
///
/// GraphQL validation makes sure all fields sharing the same response key have the same
/// arguments and are of the same type, so we only need to resolve one field.
@_spi(Execution)
public class FieldExecutionInfo {
  let field: Selection.Field
  let parentInfo: ObjectExecutionInfo

  var mergedFields: [Selection.Field]

  var responsePath: ResponsePath
  let responseKeyForField: String

  var cachePath: ResponsePath = []
  private var _cacheKeyForField: String?

  init(
    field: Selection.Field,
    parentInfo: ObjectExecutionInfo
  ) {
    self.field = field
    self.parentInfo = parentInfo
    mergedFields = [field]

    let responseKey = field.responseKey
    responsePath = parentInfo.responsePath.appending(responseKey)
    responseKeyForField = responseKey
  }

  fileprivate func computeCacheKeyAndPath() throws {
    cachePath = try parentInfo.cachePath.appending(cacheKeyForField())
  }
  
  func cacheKeyForField() throws -> String {
    guard let _cacheKeyForField else {
      let cacheKey = try field.cacheKey(with: parentInfo.variables)
      _cacheKeyForField = cacheKey
      return cacheKey
    }
    return _cacheKeyForField
  }

  /// Computes the `ObjectExecutionInfo` and selections that should be used for
  /// executing the child object.
  ///
  /// - Note: There will only be child selections if the fields for this field info are
  /// object type fields (objects; lists of objects; or non-null wrapped objects).
  /// For scalar fields, the child selections will be an empty array.
  fileprivate func computeChildExecutionData(
    withRootType rootType: any RootSelectionSet.Type,
    cacheKey: CacheKey?
  ) -> (ObjectExecutionInfo, [Selection]) {
    // If the object has it's own cache key, reset the cache path to the key,
    // rather than using the inherited cache path from the parent field.
    let cachePath: ResponsePath = {
      if let cacheKey { return [cacheKey] }
      else { return self.cachePath }
    }()

    let childExecutionInfo = ObjectExecutionInfo(
      rootType: rootType,
      variables: parentInfo.variables,
      schema: parentInfo.schema,
      responsePath: responsePath,
      cachePath: cachePath
    )
    var childSelections: [Selection] = []

    mergedFields.forEach { field in
      guard case let .object(selectionSet) = field.type.namedType else {
        return
      }
      childExecutionInfo.fulfilledFragments.insert(ObjectIdentifier(selectionSet.self))
      childSelections.append(contentsOf: selectionSet.__selections)
    }

    return (childExecutionInfo, childSelections)
  }

  func copy() -> FieldExecutionInfo {
    FieldExecutionInfo(self)
  }

  private init(_ info: FieldExecutionInfo) {
    self.field = info.field
    self.parentInfo = info.parentInfo
    self.mergedFields = info.mergedFields
    self.responsePath = info.responsePath
    self.responseKeyForField = info.responseKeyForField
    self.cachePath = info.cachePath
    self._cacheKeyForField = info._cacheKeyForField
  }

}

/// An error which has occurred during GraphQL execution.
public struct GraphQLExecutionError: Error, LocalizedError {
  let path: ResponsePath

  public var pathString: String { path.description }

  /// The error that occurred during parsing.
  public let underlying: any Error

  /// A description of the error which includes the path where the error occurred.
  public var errorDescription: String? {
    return "Error at path \"\(path))\": \(underlying)"
  }
}

/// A GraphQL executor is responsible for executing a selection set and generating a result. It is
/// initialized with a resolver closure that gets called repeatedly to resolve field values.
///
/// An executor is used both to parse a response received from the server, and to read from the 
/// normalized cache. It can also be configured with an accumulator that receives events during
/// execution, and these execution events are used by `GraphQLResultNormalizer` to normalize a
/// response into a flat set of records and by `GraphQLDependencyTracker` keep track of dependent
/// keys.
///
/// The methods in this class closely follow the
/// [execution algorithm described in the GraphQL specification]
/// (http://spec.graphql.org/draft/#sec-Execution)
@_spi(Execution)
public final class GraphQLExecutor<Source: GraphQLExecutionSource> {

  private let executionSource: Source

  public init(executionSource: Source) {
    self.executionSource = executionSource
  }

  // MARK: - Execution

  @_spi(Execution)
  public func execute<
    Accumulator: GraphQLResultAccumulator,
    SelectionSet: RootSelectionSet
  >(
    selectionSet: SelectionSet.Type,
    on data: Source.RawObjectData,
    withRootCacheReference root: CacheReference? = nil,
    variables: GraphQLOperation.Variables? = nil,
    accumulator: Accumulator
  ) async throws -> Accumulator.FinalResult {
    return try await execute(
      selectionSet: selectionSet,
      on: data,
      withRootCacheReference: root,
      variables: variables,
      schema: SelectionSet.Schema.self,
      accumulator: accumulator
    )
  }

  func execute<
    Accumulator: GraphQLResultAccumulator,
    Operation: GraphQLOperation
  >(
    selectionSet: any SelectionSet.Type,
    in operation: Operation.Type,
    on data: Source.RawObjectData,
    withRootCacheReference root: CacheReference? = nil,
    variables: GraphQLOperation.Variables? = nil,
    accumulator: Accumulator
  ) async throws -> Accumulator.FinalResult {
    return try await execute(
      selectionSet: selectionSet,
      on: data,
      withRootCacheReference: root,
      variables: variables,
      schema: Operation.Data.Schema.self,
      accumulator: accumulator
    )
  }

  private func execute<
    Accumulator: GraphQLResultAccumulator
  >(
    selectionSet: any SelectionSet.Type,
    on data: Source.RawObjectData,
    withRootCacheReference root: CacheReference? = nil,
    variables: GraphQLOperation.Variables? = nil,
    schema: (any SchemaMetadata.Type),
    accumulator: Accumulator
  ) async throws -> Accumulator.FinalResult {
    let info = ObjectExecutionInfo(
      rootType: selectionSet,
      variables: variables,
      schema: schema,
      withRootCacheReference: root
    )

    let rootValue: PossiblyDeferred<Accumulator.ObjectResult> = await execute(
      selections: selectionSet.__selections,
      on: data,
      info: info,
      accumulator: accumulator
    )

    return try await accumulator.finish(rootValue: try rootValue.get(), info: info)
  }

  private func execute<Accumulator: GraphQLResultAccumulator>(
    selections: [Selection],
    on object: Source.RawObjectData,
    info: ObjectExecutionInfo,
    accumulator: Accumulator
  ) async -> PossiblyDeferred<Accumulator.ObjectResult> {
    let fieldEntries: [PossiblyDeferred<Accumulator.FieldEntry?>] = await execute(
      selections: selections,
      on: object,
      info: info,
      accumulator: accumulator
    )

    return compactLazilyEvaluateAll(fieldEntries).map {
      try accumulator.accept(fieldEntries: $0, info: info)
    }
  }

  private func execute<Accumulator: GraphQLResultAccumulator>(
    selections: [Selection],
    on object: Source.RawObjectData,
    info: ObjectExecutionInfo,
    accumulator: Accumulator
  ) async -> [PossiblyDeferred<Accumulator.FieldEntry?>] {
    do {
      let groupedFields = try groupFields(selections, on: object, info: info)
      info.fulfilledFragments = groupedFields.fulfilledFragments
      info.deferredFragments = []

      var fieldEntries: [PossiblyDeferred<Accumulator.FieldEntry?>] = []
      fieldEntries.reserveCapacity(groupedFields.count)

      for (_, fields) in groupedFields.fieldInfoList {
        let fieldEntry = await execute(
          fields: fields,
          on: object,
          accumulator: accumulator)
        fieldEntries.append(fieldEntry)
      }

      if executionSource.shouldAttemptDeferredFragmentExecution {
        for deferredFragment in groupedFields.deferredFragments {
          guard let fragmentType = groupedFields.cachedFragmentIdentifierTypes[deferredFragment] else {
            info.deferredFragments.insert(deferredFragment)
            continue
          }

          do {
            let deferredFragmentFieldEntries = try await lazilyEvaluateAll(
              execute(
                selections: fragmentType.__selections,
                on: object,
                info: info,
                accumulator: accumulator
              )
            )
            .get()
            .compactMap { PossiblyDeferred.immediate(.success($0)) }

            fieldEntries.append(contentsOf: deferredFragmentFieldEntries)
            info.fulfilledFragments.insert(deferredFragment)

          } catch {
            info.deferredFragments.insert(deferredFragment)
            continue
          }
        }

      } else {
        info.deferredFragments = groupedFields.deferredFragments
      }

      return fieldEntries

    } catch {
      return [.immediate(.failure(error))]
    }
  }

  /// Groups fields that share the same response key for simultaneous resolution.
  ///
  /// Before execution, the selection set is converted to a grouped field set.
  /// Each entry in the grouped field set is a list of fields that share a response key.
  /// This ensures all fields with the same response key (alias or field name) included via
  /// referenced fragments are executed at the same time.
  private func groupFields(
    _ selections: [Selection],
    on object: Source.RawObjectData,
    info: ObjectExecutionInfo
  ) throws -> FieldSelectionGrouping {
    var grouping = FieldSelectionGrouping(info: info)

    try Source.FieldCollector.collectFields(
      from: selections,
      into: &grouping,
      for: object,
      info: info
    )
    return grouping
  }

  /// Each field requested in the grouped field set that is defined on the selected objectType will
  /// result in an entry in the response map. Field execution first coerces any provided argument
  /// values, then resolves a value for the field, and finally, completes that value, either by
  /// recursively executing another selection set or coercing a scalar value.
  private func execute<Accumulator: GraphQLResultAccumulator>(
    fields fieldInfo: FieldExecutionInfo,
    on object: Source.RawObjectData,
    accumulator: Accumulator
  ) async -> PossiblyDeferred<Accumulator.FieldEntry?> {
    if accumulator.requiresCacheKeyComputation {
      do {
        try fieldInfo.computeCacheKeyAndPath()
      } catch {
        return .immediate(.failure(error))
      }
    }

    return await executionSource.resolveField(with: fieldInfo, on: object)
      .flatMap {
        return await self.complete(fields: fieldInfo,
                             withValue: $0,
                             accumulator: accumulator)
      }.map {
        try accumulator.accept(fieldEntry: $0, info: fieldInfo)
      }.mapError { error in
        if !(error is GraphQLExecutionError) {
          return GraphQLExecutionError(path: fieldInfo.responsePath, underlying: error)
        } else {
          return error
        }
      }
  }

  private func complete<Accumulator: GraphQLResultAccumulator>(
    fields fieldInfo: FieldExecutionInfo,
    withValue value: JSONValue?,
    accumulator: Accumulator
  ) async -> PossiblyDeferred<Accumulator.PartialResult> {
    await complete(fields: fieldInfo,
             withValue: value,
             asType: fieldInfo.field.type,
             accumulator: accumulator)
  }

  /// After resolving the value for a field, it is completed by ensuring it adheres to the expected
  /// return type. If the return type is another Object type, then the field execution process
  /// continues recursively.
  private func complete<Accumulator: GraphQLResultAccumulator>(
    fields fieldInfo: FieldExecutionInfo,
    withValue value: JSONValue?,
    asType returnType: Selection.Field.OutputType,
    accumulator: Accumulator
  ) async -> PossiblyDeferred<Accumulator.PartialResult> {
    switch (value.asNullable, returnType) {
    case (.none, _):
      return PossiblyDeferred { try accumulator.acceptMissingValue(info: fieldInfo) }

    case (.null, .nonNull):
      return .immediate(.failure(JSONDecodingError.nullValue))

    case (.null, _):
      return PossiblyDeferred { try accumulator.acceptNullValue(info: fieldInfo) }

    case let (.some(value), .nonNull(innerType)):
      return await complete(fields: fieldInfo,
                      withValue: value,
                      asType: innerType,
                      accumulator: accumulator)

    case let (.some(value), .scalar):
      return PossiblyDeferred { try accumulator.accept(scalar: value, info: fieldInfo) }

    case let (.some(value), .customScalar):
      return PossiblyDeferred { try accumulator.accept(customScalar: value, info: fieldInfo) }

    case let (.some(value), .list(innerType)):
      guard let array = value as? [JSONValue] else {
        return PossiblyDeferred { throw JSONDecodingError.wrongType }
      }

      var completedArray: [PossiblyDeferred<Accumulator.PartialResult>] = []
      for (index, element) in array.enumerated() {
        let elementFieldInfo = fieldInfo.copy()

        let indexSegment = String(index)
        elementFieldInfo.responsePath.append(indexSegment)

        if accumulator.requiresCacheKeyComputation {
          elementFieldInfo.cachePath.append(indexSegment)
        }

        let result = await self
          .complete(
            fields: elementFieldInfo,
            withValue: element,
            asType: innerType,
            accumulator: accumulator
          )
          .mapError { error in
            if !(error is GraphQLExecutionError) {
              return GraphQLExecutionError(path: elementFieldInfo.responsePath, underlying: error)
            } else {
              return error
            }
          }
        completedArray.append(result)
      }

      return lazilyEvaluateAll(completedArray).map {
        try accumulator.accept(list: $0, info: fieldInfo)
      }

    case let (.some(value), .object(rootSelectionSetType)):
      guard let object = value as! AnyHashable as? Source.RawObjectData else {
        return PossiblyDeferred { throw JSONDecodingError.wrongType }
      }

      return await executeChildSelections(
        forObjectTypeFields: fieldInfo,
        withRootType: rootSelectionSetType,
        onChildObject: object,
        accumulator: accumulator
      )
    }
  }

  private func executeChildSelections<Accumulator: GraphQLResultAccumulator>(
    forObjectTypeFields fieldInfo: FieldExecutionInfo,
    withRootType rootSelectionSetType: any RootSelectionSet.Type,
    onChildObject object: Source.RawObjectData,
    accumulator: Accumulator
  ) async -> PossiblyDeferred<Accumulator.PartialResult> {
    let expectedInterface = rootSelectionSetType.__parentType as? Interface
    
    let (childExecutionInfo, selections) = fieldInfo.computeChildExecutionData(
      withRootType: rootSelectionSetType,
      cacheKey: executionSource.computeCacheKey(
        for: object,
        in: fieldInfo.parentInfo.schema,
        inferredToImplementInterface: expectedInterface
      )
    )
    
    return await execute(
      selections: selections,
      on: object,
      info: childExecutionInfo,
      accumulator: accumulator
    )
    .map { try accumulator.accept(childObject: $0, info: fieldInfo) }
  }
}

// MARK: - Sendable Conformance (Conditional)
@_spi(Execution)
extension GraphQLExecutor: Sendable where Source: Sendable {}
