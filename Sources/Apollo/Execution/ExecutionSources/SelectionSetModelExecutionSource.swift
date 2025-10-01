@_spi(Internal) @_spi(Execution) @_spi(Unsafe) import ApolloAPI

/// A `GraphQLExecutionSource` designed for use when the data source is a generated model's
/// `SelectionSet` data.
struct SelectionSetModelExecutionSource: GraphQLExecutionSource, CacheKeyComputingExecutionSource {
  typealias RawObjectData = DataDict
  typealias FieldCollector = CustomCacheDataWritingFieldSelectionCollector

  var shouldAttemptDeferredFragmentExecution: Bool { false }

  func resolveField(
    with info: FieldExecutionInfo,
    on object: DataDict
  ) -> PossiblyDeferred<JSONValue?> {
    .immediate(.success(object._data[info.responseKeyForField]))
  }

  func opaqueObjectDataWrapper(for rawData: DataDict) -> ObjectData {
    ObjectData(_transformer: DataTransformer(), _rawData: rawData._data)
  }

  struct DataTransformer: _ObjectData_Transformer {
    func transform(_ value: any Hashable & Sendable) -> (any ScalarType)? {
      switch value {
      case let scalar as any ScalarType:
        return scalar
      case let customScalar as any CustomScalarType:
        return customScalar._jsonValue as? (any ScalarType)
      default: return nil
      }
    }

    func transform(_ value: any Hashable & Sendable) -> ObjectData? {
      switch value {
      case let object as DataDict:
        return ObjectData(_transformer: self, _rawData: object._data)
      default: return nil
      }
    }

    func transform(_ value: any Hashable & Sendable) -> ListData? {
      switch value {
      case let list as [any Hashable & Sendable]:
        return ListData(_transformer: self, _rawData: list)
      default: return nil
      }
    }
  }
}
