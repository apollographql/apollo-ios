import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A `GraphQLExecutionSource` designed for use when the data source is a generated model's
/// `SelectionSet` data.
struct SelectionSetModelExecutionSource: GraphQLExecutionSource {
  typealias RawData = DataDict
  typealias FieldCollector = CustomCacheDataWritingFieldSelectionCollector

  static func resolveField(with info: FieldExecutionInfo, on object: DataDict) -> AnyHashable? {
    object._data[info.responseKeyForField]
  }

  static func opaqueObjectDataWrapper(for rawData: DataDict) -> OpaqueObjectDataWrapper {
    OpaqueObjectDataWrapper(underlyingData: rawData)
  }

  struct OpaqueObjectDataWrapper: ObjectData {
    let underlyingData: DataDict
    var _rawData: JSONObject { underlyingData._data  }

    subscript(_ key: String) -> AnyHashable? {
      guard let value = underlyingData._data[key] else { return nil }
      return convert(value)
    }

    func convert(_ value: AnyHashable) -> AnyHashable {
      switch value {
      case is ScalarType: return value
      case let customScalar as CustomScalarType: return customScalar._jsonValue
      default: return value
      }
    }
  }
}
