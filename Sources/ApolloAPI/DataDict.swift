/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct DataDict {

  let data: JSONObject
  let variables: GraphQLOperation.Variables?

  public init(
    _ data: JSONObject,
    variables: GraphQLOperation.Variables?
  ) {
    self.data = data
    self.variables = variables
  }

  public subscript<T: AnyScalarType>(_ key: String) -> T {
    data[key] as! T
  }

  public subscript<T: AnyScalarType>(_ key: String) -> T? {
    data[key] as? T
  }

  public subscript<T: AnyScalarType>(_ key: String) -> [T] {
    data[key] as! [T]
  }

  public subscript<T: AnyScalarType>(_ key: String) -> [T?] {
    data[key] as! [T?]
  }

  public subscript<T: AnyScalarType>(_ key: String) -> [T]? {
    data[key] as? [T]
  }

  public subscript<T: AnyScalarType>(_ key: String) -> [T?]? {
    data[key] as? [T?]
  }

  public subscript<T: AnyScalarType>(_ key: String) -> [[T]] {
    data[key] as! [[T]]
  }

  public subscript<T: AnyScalarType>(_ key: String) -> [[T]]? {
    data[key] as? [[T]]
  }
  
  public subscript<T: AnySelectionSet>(_ key: String) -> T {
    let objectData = data[key] as! JSONObject
    return T.init(data: DataDict(objectData, variables: variables))
  }

  public subscript<T: AnySelectionSet>(_ key: String) -> T? {
    guard let objectData = data[key] as? JSONObject else { return nil }
    return T.init(data: DataDict(objectData, variables: variables))
  }

  public subscript<T: AnySelectionSet>(_ key: String) -> [T] {
    let objectData = data[key] as! [JSONObject]
    return objectData.map { T.init(data: DataDict($0, variables: variables)) }
  }

  public subscript<T: AnySelectionSet>(_ key: String) -> [T]? {
    guard let objectData = data[key] as? [JSONObject] else { return nil }
    return objectData.map { T.init(data: DataDict($0, variables: variables)) }
  }
}
