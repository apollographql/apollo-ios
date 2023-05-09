import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct CacheDataExecutionSource: GraphQLExecutionSource {
  typealias RawData = JSONObject
  typealias FieldCollector = DefaultFieldSelectionCollector

  weak var transaction: ApolloStore.ReadTransaction?

  init(transaction: ApolloStore.ReadTransaction) {
    self.transaction = transaction
  }

  func resolveField(
    with info: FieldExecutionInfo,
    on object: JSONObject
  ) -> PossiblyDeferred<AnyHashable?> {
    let value = object[info.cacheKeyForField]

    switch value {
    case let reference as CacheReference:
      return deferredResolve(reference: reference).map { $0._asAnyHashable }

    case let referenceList as [CacheReference]:
      return referenceList.deferredFlatMap {
        deferredResolve(reference: $0)
      }.map { $0._asAnyHashable }

    default:
      return .immediate(.success(value))
    }
  }

  private func deferredResolve(reference: CacheReference) -> PossiblyDeferred<JSONObject> {
    guard let transaction else {
      return .immediate(.failure(ApolloStore.Error.notWithinReadTransaction))
    }

    return transaction.loadObject(forKey: reference.key)
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
