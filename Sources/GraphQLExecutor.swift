/// A resolver is responsible for resolving a value for a field.
public typealias GraphQLResolver = (_ object: JSONObject?, _ info: GraphQLResolveInfo) -> Promise<JSONValue?>

public struct GraphQLResolveInfo {
  let variables: GraphQLMap?
  
  var responsePath: [String] = []
  var responseKeyForField: String = ""
  
  var cachePath: [String] = []
  var cacheKeyForField: String = ""
  
  var fields: [Field] = []
  
  var resultMappings: [ResultMapping] = []
  
  public init(rootKey: CacheKey, variables: GraphQLMap?) {
    self.variables = variables
    
    cachePath = [rootKey]
  }
}

func joined(path: [String]) -> String {
  return path.joined(separator: ".")
}

/// A GraphQL executor is responsible for executing a selection set and generating a result. It is initialized with a resolver closure that gets called repeatedly to resolve field values.
///
/// An executor is used both to parse a response received from the server, and to read from the normalized cache. It can also be configured with a accumulator that receives events during execution, and these execution events are used by `GraphQLResultNormalizer` to normalize a response into a flat set of records and keep track of dependent keys.
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
public final class GraphQLExecutor {
  private let queue: DispatchQueue
  
  private let resolver: GraphQLResolver
  var dispatchDataLoads: (() -> Void)? = nil
  var dispatchDataLoadsScheduled: Bool = false
  
  var cacheKeyForObject: CacheKeyForObject?
  
  /// Creates a GraphQLExecutor that resolves field values by calling the provided resolver.
  public init(resolver: @escaping GraphQLResolver) {
    queue = DispatchQueue(label: "com.apollographql.GraphQLExecutor")
    
    self.resolver = resolver
  }
  
  /// Creates a GraphQLExecutor that resolves field values starting from the specified JSON root object. This could be used to execute selection sets against a JSON object received from an external source without constructing your own resolver.
  public convenience init(rootObject: JSONObject) {
    self.init { object, info in
      Promise(fulfilled: (object ?? rootObject)[info.responseKeyForField])
    }
  }
  
  private func runtimeType(of object: JSONObject?) -> String? {
    return object?["__typename"] as? String
  }
  
  private func cacheKey(for object: JSONObject) -> String? {
    guard let value = cacheKeyForObject?(object) else { return nil }
    
    if let array = value as? [Any?] {
      return array.flatMap { $0 }.map { String(describing: $0) }.joined(separator: "_")
    } else {
      return String(describing: value)
    }
  }
  
  // MARK: - Execution
  
  func execute<Accumulator: GraphQLResultAccumulator>(selectionSet: [Selection], rootKey: CacheKey, variables: GraphQLMap?, accumulator: Accumulator) throws -> Promise<Accumulator.FinalResult> {
    let info = GraphQLResolveInfo(rootKey: rootKey, variables: variables)
    
    return try execute(selectionSet: selectionSet, on: nil, info: info, accumulator: accumulator).map {
      try accumulator.finish(rootValue: $0, info: info)
    }
  }
  
  private func execute<Accumulator: GraphQLResultAccumulator>(selectionSet: [Selection], on object: JSONObject? = nil, info: GraphQLResolveInfo, accumulator: Accumulator) throws -> Promise<  Accumulator.PartialResult> {
    var info = info
    
    var groupedFields = GroupedSequence<String, Field>()
    info.resultMappings = collectFields(selectionSet: selectionSet, forRuntimeType: runtimeType(of: object), into: &groupedFields)
    
    var fieldEntries: [Promise<Accumulator.FieldEntry>] = []
    fieldEntries.reserveCapacity(groupedFields.keys.count)
    
    for (_, fields) in groupedFields {
      let fieldEntry = try execute(fields: fields, on: object, info: info, accumulator: accumulator)
      fieldEntries.append(fieldEntry)
    }
    
    if let dispatchDataLoads = dispatchDataLoads, !dispatchDataLoadsScheduled {
      dispatchDataLoadsScheduled = true
      
      queue.async {
        self.dispatchDataLoadsScheduled = false
        dispatchDataLoads()
      }
    }
    
    return whenAll(fieldEntries, notifyOn: queue).map {
      try accumulator.accept(fieldEntries: $0, info: info)
    }
  }
  
  /// Before execution, the selection set is converted to a grouped field set. Each entry in the grouped field set is a list of fields that share a response key. This ensures all fields with the same response key (alias or field name) included via referenced fragments are executed at the same time.
  private func collectFields(selectionSet: [Selection], forRuntimeType runtimeType: String?, into groupedFields: inout GroupedSequence<String, Field>) -> [ResultMapping] {
    var resultMapping: [ResultMapping] = []
    resultMapping.reserveCapacity(selectionSet.count)
    
    for selection in selectionSet {
      switch selection {
      case let field as Field:
        let (index, indexInGroup) = groupedFields.append(value: field, forKey: field.responseKey)
        resultMapping.append(.value(index: index, indexInGroup: indexInGroup))
      case let fragmentSpread as FragmentSpread:
        let fragment = fragmentSpread.fragment
        
        if let runtimeType = runtimeType, fragment.possibleTypes.contains(runtimeType) {
          let fragmentSelectionSet = fragment.selectionSet
          
          let fragmentValueMappings = collectFields(selectionSet: fragmentSelectionSet, forRuntimeType: runtimeType, into: &groupedFields)
          
          resultMapping.append(.mappable(fragment, valueMappings: fragmentValueMappings))
        } else {
          resultMapping.append(.none)
        }
      default:
        preconditionFailure()
      }
    }
    
    return resultMapping
  }
  
  /// Each field requested in the grouped field set that is defined on the selected objectType will result in an entry in the response map. Field execution first coerces any provided argument values, then resolves a value for the field, and finally completes that value either by recursively executing another selection set or coercing a scalar value.
  private func execute<Accumulator: GraphQLResultAccumulator>(fields: [Field], on object: JSONObject?, info: GraphQLResolveInfo, accumulator: Accumulator) throws -> Promise<Accumulator.FieldEntry> {
    // GraphQL validation makes sure all fields sharing the same response key have the same arguments and are of the same type, so we only need to resolve one field.
    let firstField = fields[0]
    
    var info = info
    
    let responseKey = firstField.responseKey
    info.responseKeyForField = responseKey
    info.responsePath.append(responseKey)
    
    let cacheKey = try firstField.cacheKey(with: info.variables)
    info.cacheKeyForField = cacheKey
    info.cachePath.append(cacheKey)
    
    // We still need all fields to complete the value, because they may have different selection sets.
    info.fields = fields
    
    let promise = resolver(object, info)
    
    return promise.on(queue: queue).flatMap { value in
      guard let value = value else {
        throw JSONDecodingError.missingValue
      }
      
      return try self.complete(value: value, ofType: firstField.type, info: info, accumulator: accumulator)
    }.map {
        try accumulator.accept(fieldEntry: $0, info: info)
    }.catch { error in
      if !(error is GraphQLResultError) {
       throw GraphQLResultError(path: info.responsePath, underlying: error)
      }
    }
  }
  
  /// After resolving the value for a field, it is completed by ensuring it adheres to the expected return type. If the return type is another Object type, then the field execution process continues recursively.
  private func complete<Accumulator: GraphQLResultAccumulator>(value: JSONValue, ofType returnType: GraphQLOutputType, info: GraphQLResolveInfo, accumulator: Accumulator) throws -> Promise<Accumulator.PartialResult> {
    if case .nonNull(let innerType) = returnType {
      if value is NSNull {
        return Promise(rejected: JSONDecodingError.nullValue)
      }
      
      return try complete(value: value, ofType: innerType, info: info, accumulator: accumulator)
    }
    
    if value is NSNull {
      return Promise { try accumulator.acceptNullValue(info: info) }
    }
    
    switch returnType {
    case .scalar:
      return Promise { try accumulator.accept(scalar: value, info: info) }
    case .list(let innerType):
      guard let array = value as? [JSONValue] else { return Promise(rejected: JSONDecodingError.wrongType) }
      
      return try whenAll(array.enumerated().map { index, element -> Promise<Accumulator.PartialResult> in
        var info = info
        
        let indexSegment = String(index)
        info.responsePath.append(indexSegment)
        info.cachePath.append(indexSegment)
        
        return try self.complete(value: element, ofType: innerType, info: info, accumulator: accumulator)
      }, notifyOn: queue).map { completedArray in
        return try accumulator.accept(list: completedArray, info: info)
      }
    case .object:
      guard let object = value as? JSONObject else { return Promise(rejected: JSONDecodingError.wrongType) }
      
      // The merged selection set is a list of fields from all sub‐selection sets of the original fields.
      let selectionSet = mergeSelectionSets(for: info.fields)
      
      var info = info
      if let cacheKeyForObject = self.cacheKey(for: object) {
        info.cachePath = [cacheKeyForObject]
      }
      
      // We execute the merged selection set on the object to complete the value. This is the recursive step in the GraphQL execution model.
      return try execute(selectionSet: selectionSet, on: object, info: info, accumulator: accumulator)
    default:
      preconditionFailure()
    }
  }
  
  /// When fields are selected multiple times, their selection sets are merged together when completing the value in order to continue execution of the sub‐selection sets.
  private func mergeSelectionSets(for fields: [Field]) -> [Selection] {
    var selectionSet: [Selection] = []
    for field in fields {
      if let fieldSelectionSet = field.selectionSet {
        selectionSet.append(contentsOf: fieldSelectionSet)
      }
    }
    return selectionSet
  }
}

public struct GraphQLResultError: Error, LocalizedError {
  let path: [String]
  let underlying: Error
  
  public var errorDescription: String? {
    return "Error at path \"\(joined(path: path))\": \(underlying)"
  }
}
