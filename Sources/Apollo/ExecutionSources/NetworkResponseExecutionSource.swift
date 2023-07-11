#if !COCOAPODS
import ApolloAPI
#endif

/// A `GraphQLExecutionSource` configured to execute upon the JSON data from the network response
/// for a GraphQL operation.
struct NetworkResponseExecutionSource:
  GraphQLExecutionSource,
  CacheKeyComputingExecutionSource
{
  typealias RawData = JSONObject
  typealias FieldCollector = DefaultFieldSelectionCollector

  func resolveField(
    with info: FieldExecutionInfo,
    on object: RawData
  ) -> PossiblyDeferred<AnyHashable?> {
    .immediate(.success(object[info.responseKeyForField]))
  }

  func opaqueObjectDataWrapper(for rawData: RawData) -> ObjectData {
    ObjectData(_transformer: DataTransformer(), _rawData: rawData)
  }

  struct DataTransformer: _ObjectData_Transformer {
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
      case let object as RawData:
        return ObjectData(_transformer: self, _rawData: object)
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
