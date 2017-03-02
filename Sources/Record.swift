/// A cache key for a record.
public typealias CacheKey = String

/// A cache record.
public struct Record {
  let key: CacheKey
  var fields: JSONObject
  
  init(key: CacheKey, _ fields: JSONObject = [:]) {
    self.key = key
    self.fields = fields
  }
  
  subscript(key: CacheKey) -> JSONValue? {
    get {
      return fields[key]
    }
    set {
      fields[key] = newValue
    }
  }
}

extension Record: CustomStringConvertible {
  public var description: String {
    return "#\(key) -> \(fields)"
  }
}

/// A reference to a cache record.
public struct Reference {
  let key: CacheKey
}

extension Reference: Equatable {
  public static func ==(lhs: Reference, rhs: Reference) -> Bool {
    return lhs.key == rhs.key
  }
}

extension Reference: CustomStringConvertible {
  public var description: String {
    return "-> #\(key)"
  }
}
