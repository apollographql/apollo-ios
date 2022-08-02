/// An abstract base class inherited by interfaces in a generated GraphQL schema.
/// Each `interface` defined in the GraphQL schema will have a subclass of this class generated.
public struct Interface: ParentTypeConvertible, Hashable {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}
