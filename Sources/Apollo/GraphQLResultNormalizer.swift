import Foundation

final class GraphQLResultNormalizer: GraphQLResultAccumulator {
  private var records: RecordSet = [:]

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
    return (info.cacheKeyForField, fieldEntry)
  }

  func accept(fieldEntries: [(key: String, value: JSONValue)], info: GraphQLResolveInfo) throws -> JSONValue {
    let cachePath = info.cachePath.joined

    let object = JSONObject(fieldEntries)
    records.merge(record: Record(key: cachePath, object))
    
    return Reference(key: cachePath)
  }

  func finish(rootValue: JSONValue, info: GraphQLResolveInfo) throws -> RecordSet {
    return records
  }
}
