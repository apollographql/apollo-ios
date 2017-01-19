public struct GraphQLError: Error {
  public let object: JSONObject
  
  init(_ object: JSONObject) {
    self.object = object
  }
  
  var message: String {
    return object["message"] as! String
  }
  
  var locations: [Location]? {
    return (object["locations"] as? [JSONObject])?.map(Location.init)
  }
  
  struct Location {
    let line: Int
    let column: Int
    
    init(_ object: JSONObject) {
      line = object["line"] as! Int
      column = object["column"] as! Int
    }
  }
}

extension GraphQLError: CustomDebugStringConvertible {
  public var debugDescription: String {
    return self.message
  }
}
