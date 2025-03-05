/// Represents an `interface` type in a generated GraphQL schema.
///
/// Each `interface` defined in the GraphQL schema will have an instance of ``Interface`` generated.
///
/// # See Also
/// [GraphQLSpec - Interfaces](https://spec.graphql.org/draft/#sec-Interfaces)
public struct Interface: Hashable, Sendable {
  /// The name of the ``Interface`` in the GraphQL schema.
  public let name: String
  
  /// A list of fields used to uniquely identify an instance of an object implementing this interface.
  ///
  /// This is set by adding a `@typePolicy` directive to the schema.
  public let keyFields: [String]?
  
  /// A list of name for Objects that implement this Interface
  public let implementingObjects: [String]

  /// Designated Initializer
  ///
  /// - Parameter name: The name of the ``Interface`` in the GraphQL schema.
  public init(
    name: String,
    keyFields: [String]? = nil,
    implementingObjects: [String]
  ) {
    self.name = name
    if keyFields?.isEmpty == false {
      self.keyFields = keyFields
    } else {
      self.keyFields = nil
    }
    self.implementingObjects = implementingObjects
  }
}
