@_spi(Internal) import ApolloAPI

/// A cache key for a record.
public typealias CacheKey = String

/// A cache record.
public struct Record: Sendable, Hashable {
  public let key: CacheKey

  public typealias Value = any Hashable & Sendable
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

  public static func == (lhs: Record, rhs: Record) -> Bool {
    lhs.key == rhs.key &&
    AnySendableHashable.equatableCheck(lhs.fields, rhs.fields)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
    hasher.combine(fields)
  }

}

extension Record: CustomStringConvertible {
  public var description: String {
    return "#\(key) -> \(fields)"
  }
}
