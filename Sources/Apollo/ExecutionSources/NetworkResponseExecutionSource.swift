#if !COCOAPODS
import ApolloAPI
#endif

/// A `GraphQLExecutionSource` configured to execute upon the JSON data from the network response
/// for a GraphQL operation.
@_spi(Execution)
public struct NetworkResponseExecutionSource: GraphQLExecutionSource, CacheKeyComputingExecutionSource, Sendable {
  public typealias RawObjectData = JSONObject
  public typealias FieldCollector = DefaultFieldSelectionCollector

  /// Used to determine whether deferred selections within a selection set should be executed at the same
  /// time as the other selections.
  ///
  /// When executing on a network response, deferred selections are not executed at the same time as the
  /// other selections because they are sent from the server as independent responses, are parsed
  /// sequentially, and the results are returned separately.
  public var shouldAttemptDeferredFragmentExecution: Bool { false }

  public init() {}

  public func resolveField(
    with info: FieldExecutionInfo,
    on object: JSONObject
  ) -> PossiblyDeferred<JSONValue?> {
    .immediate(.success(object[info.responseKeyForField]))
  }

  public func opaqueObjectDataWrapper(for rawData: JSONObject) -> ObjectData {
    ObjectData(_transformer: DataTransformer(), _rawData: rawData)
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
      case let object as JSONObject:
        return ObjectData(_transformer: self, _rawData: object)
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
