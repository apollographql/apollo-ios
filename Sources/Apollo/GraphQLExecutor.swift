import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A field resolver is responsible for resolving a value for a field.
typealias GraphQLFieldResolver = (_ object: JSONObject, _ info: FieldExecutionInfo) -> JSONValue?

/// A reference resolver is responsible for resolving an object based on its key. These references are
/// used in normalized records, and data for these objects has to be loaded from the cache for execution to continue.
/// Because data may be loaded from a database, these loads are batched for performance reasons.
/// By returning a `PossiblyDeferred` wrapper, we allow `ApolloStore` to use a `DataLoader` that
/// will defer loading the next batch of records from the cache until they are needed.
typealias ReferenceResolver = (CacheReference) -> PossiblyDeferred<JSONObject>

struct ObjectExecutionInfo {
  let variables: GraphQLOperation.Variables?
  let schema: SchemaMetadata.Type
  private(set) var responsePath: ResponsePath = []
  private(set) var cachePath: ResponsePath = []

  fileprivate init(
    variables: GraphQLOperation.Variables?,
    schema: SchemaMetadata.Type,
    responsePath: ResponsePath,
    cachePath: ResponsePath
  ) {
    self.variables = variables
    self.schema = schema
    self.responsePath = responsePath
    self.cachePath = cachePath
  }

  fileprivate init(
    variables: GraphQLOperation.Variables?,
    schema: SchemaMetadata.Type,
    withRootCacheReference root: CacheReference? = nil
  ) {
    self.variables = variables
    self.schema = schema
    if let root = root {
      cachePath = [root.key]
    }
  }

  fileprivate mutating func resetCachePath(toRootCacheReference root: CacheReference) {
    cachePath = [root.key]
  }
}

/// Stores the information for executing a field and all duplicate fields on the same selection set.
///
/// GraphQL validation makes sure all fields sharing the same response key have the same
/// arguments and are of the same type, so we only need to resolve one field.
struct FieldExecutionInfo {
  let field: Selection.Field
  fileprivate let parentInfo: ObjectExecutionInfo

  var mergedFields: [Selection.Field]

  var responsePath: ResponsePath
  let responseKeyForField: String

  var cachePath: ResponsePath = []
  private(set) var cacheKeyForField: String = ""

  fileprivate init(
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

  /// The selections for all child selections of the merged fields.
  ///
  /// There will only be child selections if the fields for this field info are
  /// object type fields (objects; lists of objects; or non-null wrapped objects).
  /// For scalar fields, the child selections will be an empty array.
  fileprivate func computeChildSelections() -> [Selection] {
    return mergedFields.flatMap { field -> [Selection] in
      guard case let .object(selectionSet) = field.type.namedType else {
        return []
      }
      return selectionSet.__selections
    }
  }

  /// Returns the `ExecutionInfo` that should be used for executing the child selections.
  fileprivate func executionInfoForChildSelections() -> ObjectExecutionInfo {
    return ObjectExecutionInfo(variables: parentInfo.variables,
                               schema: parentInfo.schema,
                               responsePath: responsePath,
                               cachePath: cachePath)
  }
}

fileprivate struct FieldSelectionGrouping: Sequence {
  private var fieldInfoList: [String: FieldExecutionInfo] = [:]

  var count: Int { fieldInfoList.count }

  mutating func append(field: Selection.Field, withInfo info: ObjectExecutionInfo) {
    let fieldKey = field.responseKey
    if var fieldInfo = fieldInfoList[fieldKey] {
      fieldInfo.mergedFields.append(field)
      fieldInfoList[fieldKey] = fieldInfo
    } else {
      fieldInfoList[fieldKey] = FieldExecutionInfo(field: field, parentInfo: info)
    }
  }

  func makeIterator() -> Dictionary<String, FieldExecutionInfo>.Iterator {
    fieldInfoList.makeIterator()
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
final class GraphQLExecutor {
  private let fieldResolver: GraphQLFieldResolver
  private let resolveReference: ReferenceResolver?

  var shouldComputeCachePath = true

  /// Creates a GraphQLExecutor that resolves field values by calling the provided resolver.
  /// If provided, it will also resolve references by calling the reference resolver.
  init(
    resolver: @escaping GraphQLFieldResolver,
    resolveReference: ReferenceResolver? = nil
  ) {
    self.fieldResolver = resolver
    self.resolveReference = resolveReference
  }

  private func runtimeType(of object: JSONObject) -> String? {
    return object["__typename"] as? String
  }

  // MARK: - Execution

  func execute<Accumulator: GraphQLResultAccumulator>(
    selectionSet: RootSelectionSet.Type,
    on data: JSONObject,
    withRootCacheReference root: CacheReference? = nil,
    variables: GraphQLOperation.Variables? = nil,
    accumulator: Accumulator
  ) throws -> Accumulator.FinalResult {
    let info = ObjectExecutionInfo(variables: variables,
                                   schema: selectionSet.__schema,
                                   withRootCacheReference: root)

    let rootValue = execute(selections: selectionSet.__selections,
                            on: data,
                            info: info,
                            accumulator: accumulator)

    return try accumulator.finish(rootValue: try rootValue.get(), info: info)
  }

  private func execute<Accumulator: GraphQLResultAccumulator>(
    selections: [Selection],
    on object: JSONObject,
    info: ObjectExecutionInfo,
    accumulator: Accumulator
  ) -> PossiblyDeferred<Accumulator.ObjectResult> {
    do {
      let groupedFields = try groupFields(selections, on: object, info: info)

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

  private func groupFields(
    _ selections: [Selection],
    on object: JSONObject,
    info: ObjectExecutionInfo
  ) throws -> FieldSelectionGrouping {
    var grouping = FieldSelectionGrouping()

    // Add __typename field to all selection sets other than the root of the operation.
    if !info.responsePath.isEmpty {
      grouping.append(field: .init("__typename", type: .scalar(String.self)), withInfo: info)
    }
    try groupFields(selections,
                    for: object,
                    into: &grouping,
                    info: info)
    return grouping
  }

  /// Groups fields that share the same response key for simultaneous resolution.
  ///
  /// Before execution, the selection set is converted to a grouped field set.
  /// Each entry in the grouped field set is a list of fields that share a response key.
  /// This ensures all fields with the same response key (alias or field name) included via
  /// referenced fragments are executed at the same time.
  private func groupFields(
    _ selections: [Selection],
    for object: JSONObject,
    into groupedFields: inout FieldSelectionGrouping,
    info: ObjectExecutionInfo
  ) throws {
    for selection in selections {
      switch selection {
      case let .field(field):
        groupedFields.append(field: field, withInfo: info)

      case let .conditional(conditions, selections):
        if conditions.evaluate(with: info.variables) {
          try groupFields(selections,
                          for: object,
                          into: &groupedFields,
                          info: info)
        }

      case let .fragment(fragment):
        try groupFields(fragment.__selections,
                        for: object,
                        into: &groupedFields,
                        info: info)

      case let .inlineFragment(typeCase):
        if let runtimeType = runtimeObjectType(for: object, schema: info.schema),
           typeCase.__parentType.canBeConverted(from: runtimeType) {
          try groupFields(typeCase.__selections,
                          for: object,
                          into: &groupedFields,
                          info: info)
        }
      }
    }
  }

  private func runtimeObjectType(
    for json: JSONObject,
    schema: SchemaMetadata.Type
  ) -> Object? {
    guard let __typename = json["__typename"] as? String else {
      return nil
    }
    return schema.objectType(forTypename: __typename)
  }

  /// Each field requested in the grouped field set that is defined on the selected objectType will
  /// result in an entry in the response map. Field execution first coerces any provided argument
  /// values, then resolves a value for the field, and finally, completes that value, either by
  /// recursively executing another selection set or coercing a scalar value.
  private func execute<Accumulator: GraphQLResultAccumulator>(
    fields: FieldExecutionInfo,
    on object: JSONObject,
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

    return PossiblyDeferred {
      fieldResolver(object, fieldInfo)
    }.flatMap {
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

    case .scalar, .customScalar:
      return PossiblyDeferred { try accumulator.accept(scalar: value, info: fieldInfo) }

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
            .complete(fields: elementFieldInfo,
                      withValue: element,
                      asType: innerType,
                      accumulator: accumulator)
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
    case .object:
      switch value {
      case let reference as CacheReference:
        guard let resolveReference = resolveReference else {
          return .immediate(.failure(JSONDecodingError.wrongType))
        }

        return resolveReference(reference).flatMap {
          self.complete(fields: fieldInfo,
                        withValue: $0,
                        asType: returnType,
                        accumulator: accumulator)
        }

      case let object as JSONObject:
        return executeChildSelections(forObjectTypeFields: fieldInfo,
                                      onChildObject: object,
                                      accumulator: accumulator)

      default:
        return .immediate(.failure(JSONDecodingError.wrongType))
      }    
    }
  }

  private func executeChildSelections<Accumulator: GraphQLResultAccumulator>(
    forObjectTypeFields fieldInfo: FieldExecutionInfo,
    onChildObject object: JSONObject,
    accumulator: Accumulator
  ) -> PossiblyDeferred<Accumulator.PartialResult> {
    let selections = fieldInfo.computeChildSelections()
    var childExecutionInfo = fieldInfo.executionInfoForChildSelections()

    // If the object has it's own cache key, reset the cache path to the key,
    // rather than using the inherited cache path from the parent field.
    if shouldComputeCachePath,
       let cacheKeyForObject = fieldInfo.parentInfo.schema.cacheKey(for: object) {
      childExecutionInfo.resetCachePath(toRootCacheReference: cacheKeyForObject)
    }

    return execute(selections: selections,
                   on: object,
                   info: childExecutionInfo,
                   accumulator: accumulator)
      .map { try accumulator.accept(childObject: $0, info: fieldInfo) }
  }
}
