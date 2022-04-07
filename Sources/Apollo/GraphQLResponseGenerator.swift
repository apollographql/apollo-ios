import Foundation

final class GraphQLResponseGenerator: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, info: FieldExecutionInfo) -> JSONValue {
    return scalar
  }

  func acceptNullValue(info: FieldExecutionInfo) -> JSONValue {
    return NSNull()
  }

  func accept(list: [JSONValue], info: FieldExecutionInfo) -> JSONValue {
    return list
  }

  func accept(childObject: JSONObject, info: FieldExecutionInfo) throws -> JSONValue {
    return childObject
  }

  func accept(fieldEntry: JSONValue, info: FieldExecutionInfo) -> (key: String, value: JSONValue)? {
    return (info.responseKeyForField, fieldEntry)
  }

  func accept(fieldEntries: [(key: String, value: JSONValue)], info: ObjectExecutionInfo) -> JSONObject {
    return JSONObject(fieldEntries, uniquingKeysWith: { (_, last) in last })
  }
  
  func finish(rootValue: JSONObject, info: ObjectExecutionInfo) throws -> JSONObject {
    return rootValue
  }
}
