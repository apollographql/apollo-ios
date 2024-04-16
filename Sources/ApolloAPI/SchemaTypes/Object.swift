/// Represents an object `type` in a generated GraphQL schema.
///
/// Each `type` defined in the GraphQL schema will have an instance of ``Object`` generated.
/// # See Also
/// [GraphQLSpec - Objects](https://spec.graphql.org/draft/#sec-Objects)
public struct Object: Hashable, Sendable {

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - typename: The name of the type.
  ///   - implementedInterfaces: A list of the interfaces implemented by the type.
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

  /// A helper function to determine if the receiver implements a given ``Interface`` Type.
  ///
  /// - Parameter interface: An ``Interface`` Type
  /// - Returns: A `Bool` indicating if the receiver implements the given ``Interface`` Type.
  public func implements(_ interface: Interface) -> Bool {
    implementedInterfaces.contains(where: { $0 == interface })
  }
}
