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
  let selectionSet: [Selection]?
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType, selectionSet: [Selection]? = nil) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
    self.selectionSet = selectionSet
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
