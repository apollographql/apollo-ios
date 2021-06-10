import Foundation

/// A reference to a cache record.
public struct CacheReference {
  public let key: String

  public init(key: String) {
    self.key = key
  }
}

extension CacheReference: Equatable {
  public static func ==(lhs: CacheReference, rhs: CacheReference) -> Bool {
    return lhs.key == rhs.key
  }
}

extension CacheReference: CustomStringConvertible {
  public var description: String {
    return "-> #\(key)"
  }
}
