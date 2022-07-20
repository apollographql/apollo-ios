/// An abstract base class inherited by unions in a generated GraphQL schema.
/// Each `union` defined in the GraphQL schema will have a subclass of this class generated.
public protocol Union: ParentTypeConvertible {
  static var possibleTypes: [Object.Type] { get }
}
