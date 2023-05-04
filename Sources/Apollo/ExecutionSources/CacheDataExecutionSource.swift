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

  static func opaqueObjectDataWrapper(for rawData: JSONObject) -> ObjectData {
    ObjectData(_transformer: DataTransformer(), _rawData: rawData)
  }

  struct DataTransformer: ExecutionSourceDataTransformer {
    func transform(_ value: AnyHashable) -> (any ScalarType)? {
      switch value {
      case let scalar as ScalarType:
        return scalar
      case let customScalar as CustomScalarType:
        return customScalar._jsonValue as? ScalarType
      default: return nil
      }
    }

    func transform(_ value: AnyHashable) -> ObjectData? {
      switch value {
      case let object as DataDict:
        return ObjectData(_transformer: DataTransformer(), _rawData: object._data)
      default: return nil
      }
    }

    func transform(_ value: AnyHashable) -> ListData? {
      switch value {
      case let list as [AnyHashable]:
        return ListData(_transformer: self, _rawData: list)
      default: return nil
      }
    }
  }
}
