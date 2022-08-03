public enum ParentType {

  case Object(Object)
  case Interface(Interface)
  case Union(Union)

}

// MARK: - ParentTypeConvertible

public protocol ParentTypeConvertible {
  @inlinable var asParentType: ParentType { get }
}

extension Object: ParentTypeConvertible {
  @inlinable public var asParentType: ParentType { .Object(self) }
}

extension Interface: ParentTypeConvertible {
  @inlinable public var asParentType: ParentType { .Interface(self) }
}

extension Union: ParentTypeConvertible {
  @inlinable public var asParentType: ParentType { .Union(self) }
}

// MARK: - Hashable Conformance
extension ParentType: Hashable {
  public static func == (lhs: ParentType, rhs: ParentType) -> Bool {
    switch (lhs, rhs) {
    case let (.Object(lhs), .Object(rhs)):
      return lhs == rhs
    case let (.Interface(lhs), .Interface(rhs)):
      return lhs == rhs
    case let (.Union(lhs), .Union(rhs)):
      return lhs == rhs
    default: return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
}
