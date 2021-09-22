/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct ResponseDict {

  let data: JSONObject

  public init(_ data: JSONObject) {
    self.data = data
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
    return T.init(data: ResponseDict(objectData))
  }

  public subscript<T: AnySelectionSet>(_ key: String) -> T? {
    guard let objectData = data[key] as? JSONObject else { return nil }
    return T.init(data: ResponseDict(objectData))
  }

  public subscript<T: AnySelectionSet>(_ key: String) -> [T] {
    let objectData = data[key] as! [JSONObject]
    return objectData.map { T.init(data: ResponseDict($0)) }
  }

  public subscript<T: AnySelectionSet>(_ key: String) -> [T]? {
    guard let objectData = data[key] as? [JSONObject] else { return nil }
    return objectData.map { T.init(data: ResponseDict($0)) }
  }
}
