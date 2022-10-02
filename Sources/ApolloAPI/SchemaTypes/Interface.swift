/// Represents an `interface` type in a generated GraphQL schema.
///
/// Each `interface` defined in the GraphQL schema will have an instance of ``Interface`` generated.
///
/// # See Also
/// [GraphQLSpec - Interfaces](https://spec.graphql.org/draft/#sec-Interfaces)
public struct Interface: Hashable {
  /// The name of the ``Interface`` in the GraphQL schema.
  public let name: String

  /// Designated Initializer
  ///
  /// - Parameter name: The name of the ``Interface`` in the GraphQL schema.
  public init(name: String) {
    self.name = name
  }
}
