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


//    @_disfavoredOverload
//    subscript(_ key: String) -> LazyMapSequence<Array<AnyHashable>, AnyHashable>? {
//      guard let value = underlyingData._data[key] else { return nil }
//      return convert(value)
//    }

    func _convert(_ value: AnyHashable) -> (any ScalarType)? {
      switch value {
      case let scalar as ScalarType: return scalar
      case let customScalar as CustomScalarType: return customScalar._jsonValue as? ScalarType
      default: return nil
      }
    }

    func _convert(_ value: AnyHashable) -> ObjectData? {
      switch value {
      case let object as DataDict: return OpaqueObjectDataWrapper(underlyingData: object)
      default: return nil
      }
    }

    func _convert(_ value: AnyHashable) -> ListData? {
      switch value {
      case let list as [AnyHashable]: return list.lazy.map(_convert(_:))
      default: return nil
      }
    }

//    func convert(_ value: AnyHashable) -> LazyMapSequence<Array<AnyHashable>, AnyHashable>? {
//      switch value {
//      case let list as Array<AnyHashable>: return list.lazy.map(convert(_:))
//      default: return nil
//      }
//    }
  }
}
