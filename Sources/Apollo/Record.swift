/// A cache key for a record.
public typealias CacheKey = String

/// A cache record.
public struct Record {
  public let key: CacheKey

  public typealias Value = Any
  public typealias Fields = [CacheKey: Value]
  public private(set) var fields: Fields

  public init(key: CacheKey, _ fields: Fields = [:]) {
    self.key = key
    self.fields = fields
  }

  public subscript(key: CacheKey) -> Value? {
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
  public let key: CacheKey

  public init(key: CacheKey) {
    self.key = key
  }
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
