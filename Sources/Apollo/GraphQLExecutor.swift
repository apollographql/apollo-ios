import Foundation
#if !COCOAPODS
import ApolloCore
#endif

/// A field resolver is responsible for resolving a value for a field.
typealias GraphQLFieldResolver = (_ object: JSONObject, _ info: GraphQLResolveInfo) -> JSONValue?
/// A reference resolver is responsible for resolving an object based on its key. These references are
/// used in normalized records, and data for these objects has to be loaded from the cache for execution to continue.
/// Because data may be loaded from a database, these loads are batched for performance reasons.
/// By returning a `PossiblyDeferred` wrapper, we allow `ApolloStore` to use a `DataLoader` that
/// will defer loading the next batch of records from the cache until they are needed.
typealias ReferenceResolver = (Reference) -> PossiblyDeferred<JSONObject>

struct GraphQLResolveInfo {
  let variables: GraphQLMap?

  var responsePath: ResponsePath = []
  var responseKeyForField: String = ""

  var cachePath: ResponsePath = []
  var cacheKeyForField: String = ""

  var fields: [GraphQLField] = []

  init(rootKey: CacheKey?, variables: GraphQLMap?) {
    self.variables = variables

    if let rootKey = rootKey {
      cachePath = [rootKey]
    }
  }
}

/// An error which has occurred in processing a GraphQLResult
public struct GraphQLResultError: Error, LocalizedError {
  let path: ResponsePath

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
/// The methods in this class closely follow the [execution algorithm described in the GraphQL specification](https://facebook.github.io/graphql/#sec-Execution), but an important difference is that execution returns a value for every selection in a selection set, not the merged fields. This means we get a separate result for every fragment, even though all fields that share a response key are still executed at the same time for efficiency.
///
/// So given the following query:
///
/// ```
/// query HeroAndFriendsNames {
///   hero {
///     name
///     friends {
///       name
///     }
///     ...FriendsAppearsIn
///   }
/// }
///
/// fragment FriendsAppearsIn on Character {
///   friends {
///     appearsIn
///   }
/// }
/// ```
///
/// A server would return a response with `name` and `appearsIn` merged into one object:
///
/// ```
/// ...
/// {
///   "name": "R2-D2",
///   "friends": [
///   {
///     "name": "Luke Skywalker",
///     "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]
///   }
/// }
/// ...
/// ```
///
/// The executor on the other hand, will return a separate value for every selection:
///
/// - `String`
/// - `[HeroAndFriendsNames.Data.Hero.Friend]`
/// - `FriendsAppearsIn`
///   - `[FriendsAppearsIn.Friend]`
///
/// These values then get passed into a generated `GraphQLMappable` initializer, and this is how type safe results get built up.
///
final class GraphQLExecutor {
  private let fieldResolver: GraphQLFieldResolver
  private let resolveReference: ReferenceResolver?
  
  var cacheKeyForObject: CacheKeyForObject?
  var shouldComputeCachePath = true

  /// Creates a GraphQLExecutor that resolves field values by calling the provided resolver. If provided, it will also resolve references by calling
  /// the reference resolver.
  init(resolver: @escaping GraphQLFieldResolver, resolveReference: ReferenceResolver? = nil) {
    self.fieldResolver = resolver
    self.resolveReference = resolveReference
  }

  private func runtimeType(of object: JSONObject) -> String? {
    return object["__typename"] as? String
  }

  private func cacheKey(for object: JSONObject) -> String? {
    guard let value = cacheKeyForObject?(object) else { return nil }

    if let array = value as? [Any?] {
      return array.compactMap { String(describing: $0) }.joined(separator: "_")
    } else {
      return String(describing: value)
    }
  }

  // MARK: - Execution

  func execute<Accumulator: GraphQLResultAccumulator>(selections: [GraphQLSelection],
                                                      on object: JSONObject,
                                                      withKey key: CacheKey? = nil,
                                                      variables: GraphQLMap? = nil,
                                                      accumulator: Accumulator) throws -> Accumulator.FinalResult {
    let info = GraphQLResolveInfo(rootKey: key, variables: variables)
    
    let rootValue = execute(selections: selections,
                            on: object,
                            info: info,
                            accumulator: accumulator)
    
    return try accumulator.finish(rootValue: try rootValue.get(), info: info)
  }

  private func execute<Accumulator: GraphQLResultAccumulator>(selections: [GraphQLSelection],
                                                              on object: JSONObject,
                                                              info: GraphQLResolveInfo,
                                                              accumulator: Accumulator) -> PossiblyDeferred<Accumulator.ObjectResult> {
    var groupedFields = GroupedSequence<String, GraphQLField>()
    
    do {
      try collectFields(selections: selections,
                        forRuntimeType: runtimeType(of: object),
                        into: &groupedFields,
                        info: info)
    } catch {
      return .immediate(.failure(error))
    }
    
    var fieldEntries: [PossiblyDeferred<Accumulator.FieldEntry>] = []
    fieldEntries.reserveCapacity(groupedFields.keys.count)

    for (_, fields) in groupedFields {
      let fieldEntry = execute(fields: fields,
                               on: object,
                               info: info,
                               accumulator: accumulator)
      fieldEntries.append(fieldEntry)
    }
    
    return lazilyEvaluateAll(fieldEntries).map {
      try accumulator.accept(fieldEntries: $0, info: info)
    }
  }
  
  /// Before execution, the selection set is converted to a grouped field set. Each entry in the grouped field set is a list of fields that share a response key. This ensures all fields with the same response key (alias or field name) included via referenced fragments are executed at the same time.
  private func collectFields(selections: [GraphQLSelection],
                             forRuntimeType runtimeType: String?,
                             into groupedFields: inout GroupedSequence<String, GraphQLField>,
                             info: GraphQLResolveInfo) throws {
    for selection in selections {
      switch selection {
      case let field as GraphQLField:
        _ = groupedFields.append(value: field, forKey: field.responseKey)
      case let booleanCondition as GraphQLBooleanCondition:
        guard let value = info.variables?[booleanCondition.variableName] else {
          throw GraphQLError("Variable \(booleanCondition.variableName) was not provided.")
        }
        if value as? Bool == !booleanCondition.inverted {
          try collectFields(selections: booleanCondition.selections,
                            forRuntimeType: runtimeType,
                            into: &groupedFields,
                            info: info)
        }
      case let fragmentSpread as GraphQLFragmentSpread:
        let fragment = fragmentSpread.fragment

        if let runtimeType = runtimeType, fragment.possibleTypes.contains(runtimeType) {
          try collectFields(selections: fragment.selections,
                            forRuntimeType: runtimeType,
                            into: &groupedFields,
                            info: info)
        }
      case let typeCase as GraphQLTypeCase:
        let selections: [GraphQLSelection]
        if let runtimeType = runtimeType {
          selections = typeCase.variants[runtimeType] ?? typeCase.default
        } else {
          selections = typeCase.default
        }
        try collectFields(selections: selections,
                          forRuntimeType: runtimeType,
                          into: &groupedFields,
                          info: info)
      default:
        preconditionFailure()
      }
    }
  }

  /// Each field requested in the grouped field set that is defined on the selected objectType will result in an entry in the response map. Field execution first coerces any provided argument values, then resolves a value for the field, and finally completes that value either by recursively executing another selection set or coercing a scalar value.
  private func execute<Accumulator: GraphQLResultAccumulator>(fields: [GraphQLField],
                                                              on object: JSONObject,
                                                              info: GraphQLResolveInfo,
                                                              accumulator: Accumulator) -> PossiblyDeferred<Accumulator.FieldEntry> {
    // GraphQL validation makes sure all fields sharing the same response key have the same arguments and are of the same type, so we only need to resolve one field.
    let firstField = fields[0]

    var info = info

    let responseKey = firstField.responseKey
    info.responseKeyForField = responseKey
    info.responsePath.append(responseKey)

    if shouldComputeCachePath {
      do {
        let cacheKey = try firstField.cacheKey(with: info.variables)
        info.cacheKeyForField = cacheKey
        info.cachePath.append(cacheKey)
      } catch {
        return .immediate(.failure(error))
      }
    }

    // We still need all fields to complete the value, because they may have different selection sets.
    info.fields = fields
    
    return PossiblyDeferred {
      guard let value = fieldResolver(object, info) else {
        throw JSONDecodingError.missingValue
      }
      return value
    }.flatMap {
      return self.complete(value: $0,
                           ofType: firstField.type,
                           info: info,
                           accumulator: accumulator)
    }.map {
      try accumulator.accept(fieldEntry: $0, info: info)
    }.mapError { error in
      if !(error is GraphQLResultError) {
        return GraphQLResultError(path: info.responsePath, underlying: error)
      } else {
        return error
      }
    }
  }

  /// After resolving the value for a field, it is completed by ensuring it adheres to the expected return type. If the return type is another Object type, then the field execution process continues recursively.
  private func complete<Accumulator: GraphQLResultAccumulator>(value: JSONValue,
                                                               ofType returnType: GraphQLOutputType,
                                                               info: GraphQLResolveInfo,
                                                               accumulator: Accumulator) -> PossiblyDeferred<Accumulator.PartialResult> {
    if case .nonNull(let innerType) = returnType {
      if value is NSNull {
        return .immediate(.failure(JSONDecodingError.nullValue))
      }
      
      return complete(value: value,
                      ofType: innerType,
                      info: info,
                      accumulator: accumulator)
    }
    
    if value is NSNull {
      return PossiblyDeferred { try accumulator.acceptNullValue(info: info) }
    }
    
    switch returnType {
    case .scalar:
      return PossiblyDeferred { try accumulator.accept(scalar: value, info: info) }
    case .list(let innerType):
      guard let array = value as? [JSONValue] else {
        return .immediate(.failure(JSONDecodingError.wrongType))
      }
      
      let completedArray = array.enumerated().map { index, element -> PossiblyDeferred<Accumulator.PartialResult> in
        var info = info

        let indexSegment = String(index)
        info.responsePath.append(indexSegment)
        
        if shouldComputeCachePath {
          info.cachePath.append(indexSegment)
        }
        
        return self.complete(value: element,
                             ofType: innerType,
                             info: info,
                             accumulator: accumulator)
      }
      
      return lazilyEvaluateAll(completedArray).map {
        try accumulator.accept(list: $0, info: info)
      }
    case .object:
      if let reference = value as? Reference, let resolveReference = resolveReference {
        return resolveReference(reference).flatMap {
          self.complete(value: $0,
                        ofType: returnType,
                        info: info,
                        accumulator: accumulator)
        }
      }
      
      guard let object = value as? JSONObject else {
        return .immediate(.failure(JSONDecodingError.wrongType))
      }
      
      // The merged selection set is a list of fields from all sub‐selection sets of the original fields.
      let selections = mergeSelectionSets(for: info.fields)
      
      var info = info
      if shouldComputeCachePath, let cacheKeyForObject = self.cacheKey(for: object) {
        info.cachePath = [cacheKeyForObject]
      }

      // We execute the merged selection set on the object to complete the value. This is the recursive step in the GraphQL execution model.
      return self.execute(selections: selections,
                          on: object,
                          info: info,
                          accumulator: accumulator).map { $0 as! Accumulator.PartialResult }
    default:
      preconditionFailure()
    }
  }

  /// When fields are selected multiple times, their selection sets are merged together when completing the value in order to continue execution of the sub‐selection sets.
  private func mergeSelectionSets(for fields: [GraphQLField]) -> [GraphQLSelection] {
    var selections: [GraphQLSelection] = []
    for field in fields {
      if case let .object(fieldSelections) = field.type.namedType {
        selections.append(contentsOf: fieldSelections)
      }
    }
    return selections
  }
}
