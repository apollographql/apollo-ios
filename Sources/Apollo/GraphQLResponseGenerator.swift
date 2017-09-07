import Foundation

final class GraphQLResponseGenerator: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, info: GraphQLResolveInfo) -> JSONValue {
    return scalar
  }
  
  func acceptNullValue(info: GraphQLResolveInfo) -> JSONValue {
    return NSNull()
  }
  
  func accept(list: [JSONValue], info: GraphQLResolveInfo) -> JSONValue {
    return list
  }
  
  func accept(fieldEntry: JSONValue, info: GraphQLResolveInfo) -> (key: String, value: JSONValue) {
    return (info.responseKeyForField, fieldEntry)
  }
  
  func accept(fieldEntries: [(key: String, value: JSONValue)], info: GraphQLResolveInfo) -> JSONValue {
    return JSONObject(fieldEntries)
  }
  
  func finish(rootValue: JSONValue, info: GraphQLResolveInfo) throws -> JSONObject {
    return rootValue as! JSONObject
  }
}
