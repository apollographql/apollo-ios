public protocol _ObjectData_Transformer {
  func transform(_ value: AnyHashable) -> (any ScalarType)?
  func transform(_ value: AnyHashable) -> ObjectData?
  func transform(_ value: AnyHashable) -> ListData?
}

/// An opaque wrapper for data representing a GraphQL object. This type wraps data from different
/// sources, using a `_tranformer` to ensure the raw data from different sources (which may be in
/// different formats) can be consumed with a consistent API.
public struct ObjectData {
  public let _transformer: _ObjectData_Transformer
  public let _rawData: [String: AnyHashable]

  public init(
    _transformer: _ObjectData_Transformer,
    _rawData: [String: AnyHashable]
  ) {
    self._transformer = _transformer
    self._rawData = _rawData
  }

  @inlinable public subscript(_ key: String) -> (any ScalarType)? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: String) -> ObjectData? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: String) -> ListData? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

}

public struct ListData {
  public let _transformer: _ObjectData_Transformer
  public let _rawData: [AnyHashable]

  public init(
    _transformer: _ObjectData_Transformer,
    _rawData: [AnyHashable]
  ) {
    self._transformer = _transformer
    self._rawData = _rawData
  }

  @inlinable public subscript(_ key: Int) -> (any ScalarType)? {
    return _transformer.transform(_rawData[key])
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: Int) -> ObjectData? {
    return _transformer.transform(_rawData[key])
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: Int) -> ListData? {
    return _transformer.transform(_rawData[key])
  }
}
