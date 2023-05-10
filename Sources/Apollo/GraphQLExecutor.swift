import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

class ObjectExecutionInfo {
  let rootType: any RootSelectionSet.Type
  let variables: GraphQLOperation.Variables?
  let schema: SchemaMetadata.Type
  private(set) var responsePath: ResponsePath = []
  private(set) var cachePath: ResponsePath = []
  fileprivate(set) var fulfilledFragments: Set<ObjectIdentifier>

  fileprivate init(
    rootType: any RootSelectionSet.Type,
    variables: GraphQLOperation.Variables?,
    schema: SchemaMetadata.Type,
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
    rootType: any RootSelectionSet.Type,
    variables: GraphQLOperation.Variables?,
    schema: SchemaMetadata.Type,
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

  fileprivate func resetCachePath(toRootCacheReference root: CacheReference) {
    cachePath = [root.key]
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
struct FieldExecutionInfo {
  let field: Selection.Field
  let parentInfo: ObjectExecutionInfo

  var mergedFields: [Selection.Field]

  var responsePath: ResponsePath
  let responseKeyForField: String

  var cachePath: ResponsePath = []
  private(set) var cacheKeyForField: String = ""

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

  fileprivate mutating func computeCacheKeyAndPath() throws {
    let cacheKey = try field.cacheKey(with: parentInfo.variables)
    cachePath = parentInfo.cachePath.appending(cacheKey)
    cacheKeyForField = cacheKey
  }

  /// Computes the `ObjectExecutionInfo` and selections that should be used for
  /// executing the child object.
  ///
  /// - Note: There will only be child selections if the fields for this field info are
  /// object type fields (objects; lists of objects; or non-null wrapped objects).
  /// For scalar fields, the child selections will be an empty array.
  fileprivate func computeChildExecutionData(
    withRootType rootType: any RootSelectionSet.Type,
    for object: ObjectData,
    shouldComputeCachePath: Bool
  ) -> (ObjectExecutionInfo, [Selection]) {
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

    // If the object has it's own cache key, reset the cache path to the key,
    // rather than using the inherited cache path from the parent field.
    if shouldComputeCachePath,
       let cacheKeyForObject = parentInfo.schema.cacheKey(for: object) {
      childExecutionInfo.resetCachePath(toRootCacheReference: cacheKeyForObject)
    }
    return (childExecutionInfo, childSelections)
  }

}

/// An error which has occurred during GraphQL execution.
public struct GraphQLExecutionError: Error, LocalizedError {
  let path: ResponsePath

  public var pathString: String { path.description }

  /// The error that occurred during parsing.
  public let underlying: Error

  /// A description of the error which includes the path where the error occurred.
  public var errorDescription: String? {
    return "Error at path \"\(path))\": \(underlying)"
  }
}

/// A GraphQL executor is responsible for executing a selection set and generating a result. It is initialized with a resolver closure that gets called repeatedly to resolve field values.
///
/// An executor is used both to parse a response received from the server, and to read from the normalized cache. It can also be configured with a accumulator that receives events during execution, and these execution events are used by `GraphQLResultNormalizer` to normalize a response into a flat set of records and by `GraphQLDependencyTracker` keep track of dependent keys.
///
/// The methods in this class closely follow the
/// [execution algorithm described in the GraphQL specification]
/// (http://spec.graphql.org/draft/#sec-Execution)
final class GraphQLExecutor<Source: GraphQLExecutionSource> {

  private let executionSource: Source

  var shouldComputeCachePath = true

  /// Creates a GraphQLExecutor that resolves field values by calling the provided resolver.
  /// If provided, it will also resolve references by calling the reference resolver.
  init(executionSource: Source) {
    self.executionSource = executionSource
  }

  // MARK: - Execution

  func execute<
    Accumulator: GraphQLResultAccumulator,
    SelectionSet: RootSelectionSet
  >(
    selectionSet: SelectionSet.Type,
    on data: Source.RawData,
    withRootCacheReference root: CacheReference? = nil,
    variables: GraphQLOperation.Variables? = nil,
    accumulator: Accumulator
  ) throws -> Accumulator.FinalResult {
    let info = ObjectExecutionInfo(
      rootType: SelectionSet.self,
      variables: variables,
      schema: SelectionSet.Schema.self,
      withRootCacheReference: root
    )

    let rootValue = execute(
      selections: selectionSet.__selections,
      on: data,
      info: info,
      accumulator: accumulator
    )

    return try accumulator.finish(rootValue: try rootValue.get(), info: info)
  }

  private func execute<Accumulator: GraphQLResultAccumulator>(
    selections: [Selection],
    on object: Source.RawData,
    info: ObjectExecutionInfo,
    accumulator: Accumulator
  ) -> PossiblyDeferred<Accumulator.ObjectResult> {
    do {
      let groupedFields = try groupFields(selections, on: object, info: info)
      info.fulfilledFragments = groupedFields.fulfilledFragments

      var fieldEntries: [PossiblyDeferred<Accumulator.FieldEntry?>] = []
      fieldEntries.reserveCapacity(groupedFields.count)

      for (_, fields) in groupedFields {
        let fieldEntry = execute(fields: fields,
                                 on: object,
                                 accumulator: accumulator)
        fieldEntries.append(fieldEntry)
      }
      
      return compactLazilyEvaluateAll(fieldEntries).map {
        try accumulator.accept(fieldEntries: $0, info: info)
      }

    } catch {
      return .immediate(.failure(error))
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
    on object: Source.RawData,
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
    fields: FieldExecutionInfo,
    on object: Source.RawData,
    accumulator: Accumulator
  ) -> PossiblyDeferred<Accumulator.FieldEntry?> {
    var fieldInfo = fields

    if shouldComputeCachePath {
      do {
        try fieldInfo.computeCacheKeyAndPath()
      } catch {
        return .immediate(.failure(error))
      }
    }

    return executionSource.resolveField(with: fieldInfo, on: object)
      .flatMap {
        return self.complete(fields: fieldInfo,
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
  ) -> PossiblyDeferred<Accumulator.PartialResult> {
    complete(fields: fieldInfo,
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
  ) -> PossiblyDeferred<Accumulator.PartialResult> {
    guard let value else {
      return PossiblyDeferred { try accumulator.acceptMissingValue(info: fieldInfo) }
    }

    if value is NSNull && returnType.isNullable {
      return PossiblyDeferred { try accumulator.acceptNullValue(info: fieldInfo) }
    }

    switch returnType {
    case .nonNull where value is NSNull:
        return .immediate(.failure(JSONDecodingError.nullValue))

    case let .nonNull(innerType):
      return complete(fields: fieldInfo,
                      withValue: value,
                      asType: innerType,
                      accumulator: accumulator)

    case .scalar:
      return PossiblyDeferred { try accumulator.accept(scalar: value, info: fieldInfo) }

    case .customScalar:
      return PossiblyDeferred { try accumulator.accept(customScalar: value, info: fieldInfo) }

    case .list(let innerType):
      guard let array = value as? [JSONValue] else {
        return .immediate(.failure(JSONDecodingError.wrongType))
      }

      let completedArray = array
        .enumerated()
        .map { index, element -> PossiblyDeferred<Accumulator.PartialResult> in
          var elementFieldInfo = fieldInfo

          let indexSegment = String(index)
          elementFieldInfo.responsePath.append(indexSegment)

          if shouldComputeCachePath {
            elementFieldInfo.cachePath.append(indexSegment)
          }

          return self
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
        }

      return lazilyEvaluateAll(completedArray).map {
        try accumulator.accept(list: $0, info: fieldInfo)
      }
    case let .object(rootSelectionSetType):
      guard let object = value as? Source.RawData else {
        return .immediate(.failure(JSONDecodingError.wrongType))
      }

      return executeChildSelections(
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
    onChildObject object: Source.RawData,
    accumulator: Accumulator
  ) -> PossiblyDeferred<Accumulator.PartialResult> {
    let (childExecutionInfo, selections) = fieldInfo.computeChildExecutionData(
      withRootType: rootSelectionSetType,
      for: executionSource.opaqueObjectDataWrapper(for: object),
      shouldComputeCachePath: shouldComputeCachePath
    )
    
    return execute(
      selections: selections,
      on: object,
      info: childExecutionInfo,
      accumulator: accumulator
    )
    .map { try accumulator.accept(childObject: $0, info: fieldInfo) }
  }
}
