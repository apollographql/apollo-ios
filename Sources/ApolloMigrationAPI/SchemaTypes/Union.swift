/// Represents a `union` type in a generated GraphQL schema.
///
/// Each `union` defined in the GraphQL schema will have an instance of ``Union`` generated.
///
/// # See Also
/// [GraphQLSpec - Unions](https://spec.graphql.org/draft/#sec-Unions)
public struct Union: Hashable, Sendable {
  /// The name of the ``Union`` in the GraphQL schema.
  public let name: String

  /// The ``Object`` types included in the `union`.
  public let possibleTypes: [Object]

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - name: The name of the ``Union`` in the GraphQL schema.
  ///   - possibleTypes: The ``Object`` types included in the `union`.
  public init(name: String, possibleTypes: [Object]) {
    self.name = name
    self.possibleTypes = possibleTypes
  }
  
}
