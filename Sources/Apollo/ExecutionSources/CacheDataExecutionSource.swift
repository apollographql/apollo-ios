import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct CacheDataExecutionSource: GraphQLExecutionSource {
  typealias RawData = JSONObject
  typealias FieldCollector = DefaultFieldSelectionCollector

//  weak var transaction: ApolloStore.ReadTransaction?

  func resolveField(with info: FieldExecutionInfo, on object: JSONObject) throws -> AnyHashable? {
    let value = object[info.cacheKeyForField]

//    if let reference = value as? CacheReference {
//      guard let transaction
//      return transaction?.loadObject(forKey: reference.key).get()
//    }

    return value
  }

  func opaqueObjectDataWrapper(for rawData: JSONObject) -> ObjectData {
    ObjectData(_transformer: DataTransformer(), _rawData: rawData)
  }

  struct DataTransformer: ExecutionSourceDataTransformer {
    func transform(_ value: AnyHashable) -> (any ScalarType)? {
      switch value {
      case let scalar as ScalarType:
        return scalar
      default: return nil
      }
    }

    func transform(_ value: AnyHashable) -> ObjectData? {
      switch value {
      case let object as JSONObject:
        return ObjectData(_transformer: DataTransformer(), _rawData: object)
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
