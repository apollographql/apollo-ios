@_spi(Execution)
public protocol _ObjectData_Transformer {
  func transform(_ value: any Hashable & Sendable) -> (any ScalarType)?
  func transform(_ value: any Hashable & Sendable) -> ObjectData?
  func transform(_ value: any Hashable & Sendable) -> ListData?
}

/// An opaque wrapper for data representing a GraphQL object. This type wraps data from different
/// sources, using a `_transformer` to ensure the raw data from different sources (which may be in
/// different formats) can be consumed with a consistent API.
public struct ObjectData {
  let _transformer: any _ObjectData_Transformer
  let _rawData: [String: any Hashable & Sendable]

  @_spi(Execution)
  public init(
    _transformer: any _ObjectData_Transformer,
    _rawData: [String: any Hashable & Sendable]
  ) {
    self._transformer = _transformer
    self._rawData = _rawData
  }

  public subscript(_ key: String) -> (any ScalarType)? {
    guard let rawValue = _rawData[key] else { return nil }
    var value: any Hashable & Sendable = rawValue

    // Attempting cast to `Int` to ensure we always use `Int32` vs `Int` or `Int64` for consistency and ScalarType casting,
    // also need to attempt `Bool` cast first to ensure a bool doesn't get inadvertently converted to `Int32`
    switch value {
    case let boolVal as Bool:
      value = boolVal
    case let intVal as any FixedWidthInteger:
      value = Int32(intVal)
    default:
      break
    }

    return _transformer.transform(value)
  }

  @_disfavoredOverload
  public subscript(_ key: String) -> ObjectData? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

  @_disfavoredOverload
  public subscript(_ key: String) -> ListData? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

}

/// An opaque wrapper for data representing the value for a list field on a GraphQL object.
/// This type wraps data from different sources, using a `_transformer` to ensure the raw data from
/// different sources (which may be in different formats) can be consumed with a consistent API.
public struct ListData {
  let _transformer: any _ObjectData_Transformer
  let _rawData: [any Hashable & Sendable]

  @_spi(Execution)
  public init(
    _transformer: any _ObjectData_Transformer,
    _rawData: [any Hashable & Sendable]
  ) {
    self._transformer = _transformer
    self._rawData = _rawData
  }

  public subscript(_ key: Int) -> (any ScalarType)? {
    var value: any Hashable & Sendable = _rawData[key]

    // Attempting cast to `Int` to ensure we always use `Int32` vs `Int` or `Int64` for consistency and ScalarType casting,
    // also need to attempt `Bool` cast first to ensure a bool doesn't get inadvertently converted to `Int32`
    switch value {
    case let boolVal as Bool:
      value = boolVal
    case let intVal as any FixedWidthInteger:
      value = Int32(intVal)
    default:
      break
    }

    return _transformer.transform(value)
  }

  @_disfavoredOverload
  public subscript(_ key: Int) -> ObjectData? {
    return _transformer.transform(_rawData[key])
  }

  @_disfavoredOverload
  public subscript(_ key: Int) -> ListData? {
    return _transformer.transform(_rawData[key])
  }
}
