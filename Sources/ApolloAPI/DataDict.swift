/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct DataDict {
//  public static func == (lhs: DataDict, rhs: DataDict) -> Bool {
//    lhs._data == rhs._data &&
//    lhs._variables.jsonValue == rhs._variables.jsonValue
//  }


  public let _data: JSONObject
  public let _variables: GraphQLOperation.Variables?

  @inlinable public init(
    _ data: JSONObject,
    variables: GraphQLOperation.Variables?
  ) {
    self._data = data
    self._variables = variables
  }

  @inlinable public subscript<T: AnyScalarType>(_ key: String) -> T {
    _data[key] as! T
  }
  
  @inlinable public subscript<T: AnySelectionSet>(_ key: String) -> T {
    let objectData = _data[key] as! JSONObject
    return T.init(data: DataDict(objectData, variables: _variables))
  }

  @inlinable public subscript<T: AnySelectionSet>(_ key: String) -> T? {
    guard let objectData = _data[key] as? JSONObject else { return nil }
    return T.init(data: DataDict(objectData, variables: _variables))
  }

  @inlinable public subscript<T: AnySelectionSet>(_ key: String) -> [T] {
    let objectData = _data[key] as! [JSONObject]
    return objectData.map { T.init(data: DataDict($0, variables: _variables)) }
  }

  @inlinable public subscript<T: AnySelectionSet>(_ key: String) -> [T]? {
    guard let objectData = _data[key] as? [JSONObject] else { return nil }
    return objectData.map { T.init(data: DataDict($0, variables: _variables)) }
  }
}
