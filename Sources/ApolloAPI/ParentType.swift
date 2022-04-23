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

extension Interface: ParentTypeConvertible {
  @inlinable public static var asParentType: ParentType { .Interface(Self.self) }
}

extension Union {
  @inlinable public static var asParentType: ParentType { .Union(Self.self) }
}
