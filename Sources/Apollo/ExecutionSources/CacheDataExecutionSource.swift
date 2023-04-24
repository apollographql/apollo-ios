import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct CacheDataExecutionSource: GraphQLExecutionSource {
  typealias RawData = JSONObject
  typealias FieldCollector = DefaultFieldSelectionCollector

  static func resolveField(with info: FieldExecutionInfo, on object: JSONObject) -> AnyHashable? {
    object[info.cacheKeyForField]
  }

  static func opaqueObjectDataWrapper(for rawData: JSONObject) -> OpaqueObjectDataWrapper {
    OpaqueObjectDataWrapper(underlyingData: rawData)
  }

  struct OpaqueObjectDataWrapper: ObjectData {
    let underlyingData: [String: AnyHashable]

    subscript(_ key: String) -> AnyHashable? {
      guard let value = underlyingData[key] else { return nil }
      return value
    }

    func convert(_ value: AnyHashable) -> AnyHashable {
      switch value {
      case is AnyScalarType: return value
      case let customScalar as CustomScalarType: return customScalar._jsonValue
      default: return value
      }
    }
  }
}
