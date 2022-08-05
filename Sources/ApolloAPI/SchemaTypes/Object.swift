/// An abstract base class inherited by types in a generated GraphQL schema.
/// Each `type` defined in the GraphQL schema will have a subclass of this class generated.
public struct Object: Hashable {

  public init(
    typename: String,
    implementedInterfaces: [Interface]
  ) {
    self.typename = typename
    self.implementedInterfaces = implementedInterfaces
  }

  /// A list of the interfaces implemented by the type.
  public let implementedInterfaces: [Interface]

  /// The name of the type.
  ///
  /// When an entity of the type is included in a GraphQL response its `__typename` field will
  /// match this value.
  public let typename: String

  /// A helper function to determine if the receiver implement's a given ``Interface`` Type.
  ///
  /// - Parameter interface: An ``Interface`` Type
  /// - Returns: A `Bool` indicating if the receiver implements the given ``Interface`` Type.
  public func implements(_ interface: Interface) -> Bool {
    implementedInterfaces.contains(where: { $0 == interface })
  }

  public static func == (lhs: Object, rhs: Object) -> Bool {
    return lhs.typename == rhs.typename &&
    lhs.implementedInterfaces == rhs.implementedInterfaces
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(typename)
    hasher.combine(implementedInterfaces)
  }
}
