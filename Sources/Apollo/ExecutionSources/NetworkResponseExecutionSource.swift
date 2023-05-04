import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct NetworkResponseExecutionSource: GraphQLExecutionSource {
  typealias RawData = JSONObject
  typealias FieldCollector = DefaultFieldSelectionCollector

  static func resolveField(with info: FieldExecutionInfo, on object: JSONObject) -> AnyHashable? {
    object[info.responseKeyForField]
  }

  static func opaqueObjectDataWrapper(for rawData: JSONObject) -> OpaqueObjectDataWrapper {
    OpaqueObjectDataWrapper(_rawData: rawData)
  }

  struct OpaqueObjectDataWrapper: ObjectData {
    let _rawData: [String: AnyHashable]

    func _convert(_ value: AnyHashable) -> (any ScalarType)? {
      switch value {
      case let scalar as ScalarType: return scalar
      case let customScalar as CustomScalarType: return customScalar._jsonValue as? ScalarType
      default: return nil
      }
    }

    func _convert(_ value: AnyHashable) -> ObjectData? {
      switch value {
      case let object as [String: AnyHashable]: return OpaqueObjectDataWrapper(_rawData: object)
      default: return nil
      }
    }
  }
}
