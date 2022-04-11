import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

final class GraphQLResultNormalizer: GraphQLResultAccumulator {
  private var records: RecordSet = [:]

  func accept(scalar: JSONValue, info: FieldExecutionInfo) -> JSONValue {
    return scalar
  }

  func acceptNullValue(info: FieldExecutionInfo) -> JSONValue {
    return NSNull()
  }

  func accept(list: [JSONValue], info: FieldExecutionInfo) -> JSONValue {
    return list
  }

  func accept(childObject: CacheReference, info: FieldExecutionInfo) throws -> JSONValue {
    return childObject
  }

  func accept(fieldEntry: JSONValue, info: FieldExecutionInfo) -> (key: String, value: JSONValue)? {
    return (info.cacheKeyForField, fieldEntry)
  }

  func accept(
    fieldEntries: [(key: String, value: JSONValue)],
    info: ObjectExecutionInfo
  ) throws -> CacheReference {
    let cachePath = info.cachePath.joined

    let object = JSONObject(fieldEntries, uniquingKeysWith: { (_, last) in last })
    records.merge(record: Record(key: cachePath, object))
    
    return CacheReference(cachePath)
  }

  func finish(rootValue: CacheReference, info: ObjectExecutionInfo) throws -> RecordSet {
    return records
  }
}
