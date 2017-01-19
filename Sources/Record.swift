public typealias Key = String

public struct Record {
  let key: Key
  var fields: JSONObject
  
  init(key: Key, _ fields: JSONObject = [:]) {
    self.key = key
    self.fields = fields
  }
  
  subscript(key: Key) -> JSONValue? {
    get {
      return fields[key]
    }
    set {
      fields[key] = newValue
    }
  }
}

public struct Reference {
  let key: Key
}

extension Reference: Equatable {
  public static func == (lhs: Reference, rhs: Reference) -> Bool {
    return lhs.key == rhs.key
  }
}
