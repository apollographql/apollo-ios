import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A `GraphQLExecutionSource` designed for use when the data source is a generated model's
/// `SelectionSet` data.
struct SelectionSetModelExecutionSource: GraphQLExecutionSource {
  typealias RawData = DataDict
  typealias FieldCollector = CustomCacheDataWritingFieldSelectionCollector

  func resolveField(with info: FieldExecutionInfo, on object: DataDict) -> AnyHashable? {
    object._data[info.responseKeyForField]
  }

  func opaqueObjectDataWrapper(for rawData: DataDict) -> ObjectData {
    ObjectData(_transformer: DataTransformer(), _rawData: rawData._data)
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
