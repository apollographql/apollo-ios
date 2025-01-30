import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

enum ResultNormalizerFactory {

  static func selectionSetDataNormalizer() -> SelectionSetDataResultNormalizer {
    SelectionSetDataResultNormalizer()
  }

  static func networkResponseDataNormalizer() -> RawJSONResultNormalizer {
    RawJSONResultNormalizer()
  }
}

class BaseGraphQLResultNormalizer: GraphQLResultAccumulator {
  
  let requiresCacheKeyComputation: Bool = true

  private var records: RecordSet = [:]

  fileprivate init() {}

  final func accept(scalar: JSONValue, info: FieldExecutionInfo) -> JSONValue? {
    return scalar
  }

  func accept(customScalar: JSONValue, info: FieldExecutionInfo) -> JSONValue? {
    return customScalar
  }

  final func acceptNullValue(info: FieldExecutionInfo) -> JSONValue? {
    return NSNull()
  }

  final func acceptMissingValue(info: FieldExecutionInfo) -> JSONValue? {
    return nil
  }

  final func accept(list: [JSONValue?], info: FieldExecutionInfo) -> JSONValue? {
    return list as JSONValue
  }

  final func accept(childObject: CacheReference, info: FieldExecutionInfo) -> JSONValue? {
    return childObject
  }

  final func accept(fieldEntry: JSONValue?, info: FieldExecutionInfo) throws -> (key: String, value: JSONValue)? {
    guard let fieldEntry else { return nil }
    return (try info.cacheKeyForField(), fieldEntry)
  }

  final func accept(
    fieldEntries: [(key: String, value: JSONValue)],
    info: ObjectExecutionInfo
  ) throws -> CacheReference {
    let cachePath = info.cachePath.joined

    let object = JSONObject(fieldEntries, uniquingKeysWith: { (_, last) in last })
    records.merge(record: Record(key: cachePath, object))

    return CacheReference(cachePath)
  }

  final func finish(rootValue: CacheReference, info: ObjectExecutionInfo) throws -> RecordSet {
    return records
  }
}

final class RawJSONResultNormalizer: BaseGraphQLResultNormalizer {}

final class SelectionSetDataResultNormalizer: BaseGraphQLResultNormalizer {
  override final func accept(customScalar: JSONValue, info: FieldExecutionInfo) -> JSONValue? {
    if let customScalar = customScalar as? (any JSONEncodable) {
      return customScalar._jsonValue
    }
    return customScalar
  }
}
