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
  ///   - keyFields: A list of field names that are used to uniquely identify an instance of this type.
  public init(
    typename: String,
    implementedInterfaces: [Interface],
    keyFields: [String]? = nil
  ) {
    self.typename = typename
    self._implementedInterfaces = implementedInterfaces
    if keyFields?.isEmpty == false {
      self.keyFields = keyFields
    } else {
      self.keyFields = nil
    }
  }

  private let _implementedInterfaces: [Interface]
  
  /// A list of the interfaces implemented by the type.
  @available(*, deprecated, message: "This property will be removed in version 2.0. To check if an Object implements an interface please use the 'implements(_)' function.")
  public var implementedInterfaces: [Interface] {
    return _implementedInterfaces
  }

  /// The name of the type.
  ///
  /// When an entity of the type is included in a GraphQL response its `__typename` field will
  /// match this value.
  public let typename: String
  
  /// A list of fields used to uniquely identify an instance of this object.
  ///
  /// This is set by adding a `@typePolicy` directive to the schema.
  public let keyFields: [String]?

  /// A helper function to determine if the receiver implements a given ``Interface`` Type.
  ///
  /// - Parameter interface: An ``Interface`` Type
  /// - Returns: A `Bool` indicating if the receiver implements the given ``Interface`` Type.
  public func implements(_ interface: Interface) -> Bool {
    interface.implementingObjects.contains(typename)
  }
}
