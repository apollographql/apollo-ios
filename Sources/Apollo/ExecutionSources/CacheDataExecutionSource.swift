import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct CacheDataExecutionSource: GraphQLExecutionSource {
  typealias RawData = Record
  typealias FieldCollector = CacheDataFieldSelectionCollector

  weak var transaction: ApolloStore.ReadTransaction?

  init(transaction: ApolloStore.ReadTransaction) {
    self.transaction = transaction
  }

  func resolveField(
    with info: FieldExecutionInfo,
    on object: Record
  ) -> PossiblyDeferred<AnyHashable?> {
    let value = object[info.cacheKeyForField]

    switch value {
    case let reference as CacheReference:
      return deferredResolve(reference: reference).map { $0 as AnyHashable }

    case let referenceList as [CacheReference]:
      return referenceList
        .enumerated()
        .deferredFlatMap { index, element in
          self.deferredResolve(reference: element)
            .mapError { error in
              if !(error is GraphQLExecutionError) {
                return GraphQLExecutionError(
                  path: info.responsePath.appending(String(index)),
                  underlying: error
                )
              } else {
                return error
              }
            }
        }.map { $0._asAnyHashable }

    default:
      return .immediate(.success(value))
    }
  }

  private func deferredResolve(reference: CacheReference) -> PossiblyDeferred<Record> {
    guard let transaction else {
      return .immediate(.failure(ApolloStore.Error.notWithinReadTransaction))
    }

    return transaction.loadObject(forKey: reference.key)
  }

  func computeCacheKey(for object: Record, in schema: SchemaMetadata.Type) -> CacheKey? {
    return object.key
  }

//  func opaqueObjectDataWrapper(for rawData: Record) -> ObjectData {
//    ObjectData(_transformer: DataTransformer(transaction: transaction), _rawData: rawData.fields)
//  }

//  struct DataTransformer: ExecutionSourceDataTransformer {
//    weak var transaction: ApolloStore.ReadTransaction?
//
//    func transform(_ value: AnyHashable) -> (any ScalarType)? {
//      switch value {
//      case let scalar as ScalarType:
//        return scalar
//      default: return nil
//      }
//    }
//
//    func transform(_ value: AnyHashable) -> ObjectData? {
//      switch value {
//      case let object as JSONObject:
//        return ObjectData(_transformer: self, _rawData: object)
//
//      case let reference as CacheReference:
//        guard let data = try? transaction?.loadObject(forKey: reference.key).get() else {
//          return nil
//        }
//
//        return ObjectData(_transformer: self, _rawData: data.fields)
//
//      default: return nil
//      }
//    }
//
//    func transform(_ value: AnyHashable) -> ListData? {
//      switch value {
//      case let list as [AnyHashable]:
//        return ListData(_transformer: self, _rawData: list)
//      default: return nil
//      }
//    }
//  }
  struct CacheDataFieldSelectionCollector: FieldSelectionCollector {
    static func collectFields(
      from selections: [Selection],
      into groupedFields: inout FieldSelectionGrouping,
      for object: Record,
      info: ObjectExecutionInfo
    ) throws {
      return try DefaultFieldSelectionCollector.collectFields(
        from: selections,
        into: &groupedFields,
        for: object.fields,
        info: info
      )
    }
  }
}


