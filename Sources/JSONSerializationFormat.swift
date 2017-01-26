final class JSONSerializationFormat {
  class func serialize(value: GraphQLInputValue) throws -> Data {
    return try JSONSerialization.data(withJSONObject: value.jsonValue, options: [])
  }
  
  class func deserialize(data: Data) throws -> JSONValue {
    return try JSONSerialization.jsonObject(with: data, options: [])
  }
}
