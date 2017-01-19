public struct GraphQLError: Error {
  private let object: JSONObject
  
  init(_ object: JSONObject) {
    self.object = object
  }
  
  public subscript(key: String) -> Any? {
    return object[key]
  }
  
  public var message: String {
    return self["message"] as! String
  }
  
  public var locations: [Location]? {
    return (self["locations"] as? [JSONObject])?.map(Location.init)
  }
  
  public struct Location {
    public let line: Int
    public let column: Int
    
    init(_ object: JSONObject) {
      line = object["line"] as! Int
      column = object["column"] as! Int
    }
  }
}

extension GraphQLError: CustomStringConvertible {
  public var description: String {
    return self.message
  }
}
