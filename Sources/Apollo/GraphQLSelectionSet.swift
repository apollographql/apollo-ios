public typealias Snapshot = [String: Any?]

public protocol GraphQLSelectionSet {
  static var selections: [Selection] { get }
  static var possibleTypes: [String] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
  init(jsonObject: JSONObject) throws {
    let executor = GraphQLExecutor { object, info in
      Promise(fulfilled: object[info.responseKeyForField])
    }
    executor.shouldComputeCachePath = false
    self = try executor.execute(selections: Self.selections, on: jsonObject, accumulator: GraphQLSelectionSetMapper<Self>()).await()
  }
  
  var jsonObject: JSONObject {
    return snapshot.jsonObject
  }
}

extension GraphQLSelectionSet {  
  public init(_ selectionSet: GraphQLSelectionSet) throws {
    try self.init(jsonObject: selectionSet.jsonObject)
  }
}

public protocol Selection {
}

public struct Field: Selection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
  
  func cacheKey(with variables: [String: JSONEncodable]?) throws -> String {
    if let argumentValues = try arguments?.evaluate(with: variables), !argumentValues.isEmpty {
      let argumentsKey = orderIndependentKey(for: argumentValues)
      return "\(name)(\(argumentsKey))"
    } else {
      return name
    }
  }
}

private func orderIndependentKey(for object: JSONObject) -> String {
  return object.sorted { $0.key < $1.key }.map {
    if let object = $0.value as? JSONObject {
      return "[\($0.key):\(orderIndependentKey(for: object))]"
    } else {
      return "\($0.key):\($0.value)"
    }
  }.joined(separator: ",")
}

public struct FragmentSpread: Selection {
  let fragment: GraphQLFragment.Type
  
  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}
