func equals(_ lhs: Any, _ rhs: Any) -> Bool {
  if let lhs = lhs as? AnyEquatable, let rhs = rhs as? AnyEquatable {
    return lhs.isEqual(rhs)
  } else {
    return false
  }
}

public protocol AnyEquatable {
  func isEqual(_ other: AnyEquatable) -> Bool
}

extension AnyEquatable {
  public func isEqual(_ other: AnyEquatable) -> Bool {
    return false
  }
}

extension AnyEquatable where Self: Equatable {
  public func isEqual(_ other: AnyEquatable) -> Bool {
    if let other = other as? Self {
      return other == self
    }
    return false
  }
}

extension Bool: AnyEquatable {}
extension Int: AnyEquatable {}
extension Float: AnyEquatable {}
extension Double: AnyEquatable {}
extension String: AnyEquatable { }
extension Array: AnyEquatable {}
extension Dictionary: AnyEquatable {}
extension NSNull: AnyEquatable {}

extension Reference: AnyEquatable {}
