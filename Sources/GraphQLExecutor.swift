public typealias GraphQLResolver = (_ field: Field, _ object: JSONObject?, _ info: GraphQLResolveInfo) -> JSONValue?

public final class GraphQLResolveInfo {
  var path: [String] = []
  let variables: GraphQLMap?
  
  init(variables: GraphQLMap?) {
    self.variables = variables
  }
}

/// A (usually code generated) type that can be initialized with an array of values that correspond to the order of the selections in a particular selection set.
public protocol GraphQLMappable {
  init(values: [Any?])
}

protocol GraphQLExecutorDelegate: class {
  func willResolve(field: Field, info: GraphQLResolveInfo)
  func didResolve(field: Field, info: GraphQLResolveInfo)
  func didComplete(scalar: JSONValue)
  func didCompleteValueWithNull()
  func willComplete(object: JSONObject)
  func didComplete(object: JSONObject)
  func willComplete<Element>(array: [Element])
  func willCompleteElement(at index: Int)
  func didCompleteElement(at index: Int)
  func didComplete<Element>(array: [Element])
}

/// A GraphQL executor is responsible for executing a selection set and generating a result. It is initialized with a resolver closure that gets called repeatedly to resolve field values.
///
/// An executor is used both to parse a response received from the server, and to read from the normalized cache. It can also be configured with a delegate that receives events during execution, and these execution events are used by `GraphQLResultNormalizer` to normalize a response into a flat set of records and keep track of dependent keys.
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
  let resolver: GraphQLResolver
  var delegate: GraphQLExecutorDelegate?
  
  private var resolveInfo: GraphQLResolveInfo
  
  /// Creates a GraphQLExecutor that resolves field values by calling the provided resolver.
  init(variables: GraphQLMap? = [:], resolver: @escaping GraphQLResolver) {
    self.resolver = resolver
    resolveInfo = GraphQLResolveInfo(variables: variables)
  }
  
  /// Creates a GraphQLExecutor that resolves field values starting from the specified JSON root object. This could be used to execute selection sets against a JSON object received from an external source without constructing your own resolver.
  public convenience init(rootObject: JSONObject, variables: GraphQLMap? = [:]) {
    self.init(variables: variables) { field, object, info in
      return (object ?? rootObject)[field.responseKey]
    }
  }
  
  private func runtimeType(of object: JSONObject?) -> String? {
    return object?["__typename"] as? String
  }
  
  // MARK: - Execution
  
  typealias Result = Any?
  typealias ResultMap = [String: [Result]]
  typealias ResultExtractor = (ResultMap) -> Result
  
  public func execute<Mappable: GraphQLMappable>(selectionSet: [Selection], on object: JSONObject? = nil) throws -> Mappable {
    let values = try execute(selectionSet: selectionSet)
    return Mappable.init(values: values)
  }
  
  func execute(selectionSet: [Selection], on object: JSONObject? = nil) throws -> [Result] {
    // Result extractors are closures that return a value based on the passed in result map. We need this indirection mechanism because some selections result in composite values (e.g. for fragments), and we need to extract multiple results from the map to constuct these.
    // We pass in groupedFieldSet as an inout parameter because we need the order of the fields to remain stable in recursive invocations of collectFields.
    var groupedFieldSet: [String: [Field]] = [:]
    let resultExtractors = collectFields(selectionSet: selectionSet, forRuntimeType: runtimeType(of: object), into: &groupedFieldSet)
    
    // The result map will contain a list of values for all fields sharing the same response key.
    var resultMap: ResultMap = [:]
    
    for (responseKey, fields) in groupedFieldSet {
      let responseValue: [Result] = try execute(fields: fields, on: object)
      resultMap[responseKey] = responseValue
    }
    
    return resultExtractors.map { $0?(resultMap) }
  }
  
  /// Before execution, the selection set is converted to a grouped field set. Each entry in the grouped field set is a list of fields that share a response key. This ensures all fields with the same response key (alias or field name) included via referenced fragments are executed at the same time.
  private func collectFields(selectionSet: [Selection], forRuntimeType runtimeType: String?, into groupedFieldSet: inout [String: [Field]]) -> [ResultExtractor?] {
    var resultExtractors: [ResultExtractor?] = []
    resultExtractors.reserveCapacity(selectionSet.count)
    
    for selection in selectionSet {
      switch selection {
      case let field as Field:
        let responseKey = field.responseKey
        let index: Int
        if var groupForResponseKey = groupedFieldSet[responseKey] {
          index = groupForResponseKey.count
          groupForResponseKey.append(field)
          groupedFieldSet[responseKey] = groupForResponseKey
        } else {
          index = 0
          groupedFieldSet[responseKey] = [field]
        }
        // We keep track of the index in the group for a particular response key, and use that to extract the value.
        resultExtractors.append({ $0[responseKey]?[index] })
      case let fragmentSpread as FragmentSpread:
        let fragment = fragmentSpread.fragment
        
        if let runtimeType = runtimeType, fragment.possibleTypes.contains(runtimeType) {
          let fragmentSelectionSet = fragment.selectionSet
          
          // The fragment result extractors correspond to the values needed to construct the fragment.
          let fragmentResultExtractors = collectFields(selectionSet: fragmentSelectionSet, forRuntimeType: runtimeType, into: &groupedFieldSet)
          
          // We then append a composite result extractor that invokes the fragment result extractors and instantiates the fragment.
          resultExtractors.append({ resultMap in
            let values = fragmentResultExtractors.map { $0?(resultMap) }
            return fragment.init(values: values)
          })
        } else {
          // If the type condition of the fragment doesn't match the current object, the result will be nil
          resultExtractors.append(nil)
        }
      default:
        preconditionFailure()
      }
    }
    
    return resultExtractors
  }

  /// Each field requested in the grouped field set that is defined on the selected objectType will result in an entry in the response map. Field execution first coerces any provided argument values, then resolves a value for the field, and finally completes that value either by recursively executing another selection set or coercing a scalar value.
  private func execute(fields: [Field], on object: JSONObject?) throws -> [Result] {
    // GraphQL validation makes sure all fields sharing the same response key have the same arguments and are of the same type, so we only need to resolve one field.
    // We still need all fields to complete the value, because they may have different selection sets.
    let firstField = fields[0]
    
    return try resolve(field: firstField, on: object) { value in
      try complete(value: value, ofType: firstField.type, for: fields)
    }
  }
  
  /// Produces a value for a given field on an object by calling the resolver.
  private func resolve<T>(field: Field, on object: JSONObject?, _ body: (JSONValue) throws -> T) throws -> T {
    resolveInfo.path.append(field.responseKey)
    delegate?.willResolve(field: field, info: resolveInfo)
    
    do {
      guard let result = resolver(field, object, resolveInfo) else {
        throw JSONDecodingError.missingValue
      }
      
      // TODO: Allow the resolver to return values asynchronously.
      let value = try body(result)
      
      resolveInfo.path.removeLast()
      delegate?.didResolve(field: field, info: resolveInfo)
      
      return value
    } catch let error as JSONDecodingError {
      throw GraphQLResultError(path: resolveInfo.path, underlying: error)
    }
  }
  
  /// After resolving the value for a field, it is completed by ensuring it adheres to the expected return type. If the return type is another Object type, then the field execution process continues recursively.
  private func complete(value: JSONValue, ofType returnType: GraphQLOutputType, for fields: [Field]) throws -> [Result] {
    if case .nonNull(let innerType) = returnType {
      let completedValue = try complete(value: value, ofType: innerType, for: fields)
      if completedValue[0] == nil {
        throw JSONDecodingError.nullValue
      }
      return completedValue
    }
    
    if value is NSNull {
      delegate?.didCompleteValueWithNull()
      return Array(repeating: nil, count: fields.count)
    }
    
    switch returnType {
    case .list(let innerType):
      guard let array = value as? [JSONValue] else { throw JSONDecodingError.wrongType }
      
      delegate?.willComplete(array: array)
      
      // We build up multiple arrays in parallel, one per original field. By recursively completing values, we also make sure to support nested arrays of arbitrary depth.
      
      var completedValues: [[Any?]] = Array(repeating: [], count: fields.count)
      
      for (index, element) in array.enumerated() {
        delegate?.willCompleteElement(at: index)
        
        let completedValuesForElement = try complete(value: element, ofType: innerType, for: fields)
        
        for (index, completedValue) in completedValuesForElement.enumerated() {
          completedValues[index].append(completedValue)
        }
        
        delegate?.didCompleteElement(at: index)
      }
      
      delegate?.didComplete(array: array)
      
      return completedValues
    case .object:
      guard let object = value as? JSONObject else { throw JSONDecodingError.wrongType }
      
      delegate?.willComplete(object: object)
      
      // The merged selection set is a list of fields from all sub‐selection sets of the original fields.
      let selectionSet = mergeSelectionSets(for: fields)
      
      // We execute the merged selection set on the object to get a list of values. This is the recursive step in the GraphQL execution model.
      let selectionValues: [Result] = try execute(selectionSet: selectionSet, on: object)
      
      // We then map over the original fields, extract the values that correspond to their sub-selections, and use these to initialize a compound value.
      
      var startIndex = selectionValues.startIndex
      
      let completedValue: [Result] = fields.map { field in
        guard case .object(let mappable) = field.type.namedType else { preconditionFailure() }
        
        let endIndex = startIndex.advanced(by: field.selectionSet!.count)
        let values = selectionValues[startIndex..<endIndex]
        startIndex = endIndex
 
        return mappable.init(values: Array(values))
      }
      
      delegate?.didComplete(object: object)
      
      return completedValue
    case .scalar:
      delegate?.didComplete(scalar: value)
      
      return try fields.map { field in
        guard case .scalar(let decodable) = field.type.namedType else { preconditionFailure() }
        // This will convert a JSON value to the expected return type, which could be a custom scalar or an enum.
        return try decodable.init(jsonValue: value)
      }
    default:
      preconditionFailure()
    }
  }
  
  /// When more than one fields of the same name are executed in parallel, their selection sets are merged together when completing the value in order to continue execution of the sub‐selection sets.
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
  
  public var pathDescription: String {
    return path.joined(separator: ".")
  }
  
  public var errorDescription: String? {
    return "Error while reading path \"\(pathDescription)\": \(underlying)"
  }
}
