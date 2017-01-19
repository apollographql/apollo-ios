public struct Field {
  let responseName: String
  let fieldName: String
  let arguments: GraphQLMap?
  
  let cacheKey: String
  
  public init(responseName: String, fieldName: String? = nil, arguments: GraphQLMap? = nil) {
    self.responseName = responseName
    self.fieldName = fieldName ?? responseName
    self.arguments = arguments
    
    if let arguments = arguments?.jsonObject, !arguments.isEmpty {
      let argumentsKey = orderIndependentKey(for: arguments)
      cacheKey = "\(self.fieldName)(\(argumentsKey))"
    } else {
      cacheKey = self.fieldName
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
