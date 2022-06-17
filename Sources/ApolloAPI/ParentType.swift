public enum ParentType {

  case Object(Object.Type)
  case Interface(Interface.Type)
  case Union(Union.Type)

}

// MARK: - ParentTypeConvertible

public protocol ParentTypeConvertible {
  @inlinable static var asParentType: ParentType { get }
}

extension Object: ParentTypeConvertible {
  @inlinable public static var asParentType: ParentType { .Object(Self.self) }
}

extension Interface {
  @inlinable public static var asParentType: ParentType { .Interface(Self.self) }
}

extension Union {
  @inlinable public static var asParentType: ParentType { .Union(Self.self) }
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
