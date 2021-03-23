/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct ResponseDict {

  let data: [String: Any]

  public subscript<T: ScalarType>(_ key: String) -> T {
    data[key] as! T
  }

  public subscript<T:ScalarType>(_ key: String) -> T? {
    data[key] as? T
  }

  public subscript<T: SelectionSet>(_ key: String) -> T {
    let entityData = data[key] as! [String: Any]
    return T.init(data: ResponseDict(data: entityData))
  }

  public subscript<T: SelectionSet>(_ key: String) -> T? {
    guard let entityData = data[key] as? [String: Any] else { return nil }
    return T.init(data: ResponseDict(data: entityData))
  }

  public subscript<T: SelectionSet>(_ key: String) -> [T] {
    let entityData = data[key] as! [[String: Any]]
    return entityData.map { T.init(data: ResponseDict(data: $0)) }
  }

  public subscript<T>(_ key: String) -> GraphQLEnum<T> {
    let entityData = data[key] as! String
    return GraphQLEnum(rawValue: entityData)
  }

  public subscript<T>(_ key: String) -> GraphQLEnum<T>? {
    guard let entityData = data[key] as? String else { return nil }
    return GraphQLEnum(rawValue: entityData)
  }
}
