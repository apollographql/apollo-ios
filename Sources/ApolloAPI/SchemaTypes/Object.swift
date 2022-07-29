/// An abstract base class inherited by types in a generated GraphQL schema.
/// Each `type` defined in the GraphQL schema will have a subclass of this class generated.
open class Object: Hashable {
  public static func == (lhs: Object, rhs: Object) -> Bool {
    #warning("TODO: interfaces?")
    return lhs.__typename == rhs.__typename
  }

  public func hash(into hasher: inout Hasher) {
  #warning("TODO: interfaces?")
    hasher.combine(__typename)
  }

  public init() {}

  /// A list of the interfaces implemented by the type.
  open var __implementedInterfaces: [Interface.Type]? { nil }

  /// The name of the type.
  ///
  /// When an entity of the type is included in a GraphQL response its `__typename` field will
  /// match this value.
  ///
  /// Defaults to `"∅__UnknownType"` for a type that is not included in the schema at the time of
  /// code generation.
  open var __typename: String { Object.UnknownTypeName.description }
  open class var __typename: StaticString { Object.UnknownTypeName }

  static let UnknownTypeName: StaticString = "∅__UnknownType"

  /// A helper function to determine if an entity of the receiver's type can be converted to
  /// a given ``ParentType``.
  ///
  /// A type can be converted to an `interface` type if only if the type implements the interface.
  /// (ie. The ``Interface``.Type is contained in the ``Object``'s ``Object/implementedInterfaces``.)
  ///
  /// A type can be converted to a `union` type if only if the union includes the type.
  /// (ie. The ``Object`` Type is contained in the ``Union``'s ``Union/possibleTypes``.)
  ///
  /// - Parameter otherType: A ``ParentType`` to determine conversion compatibility for
  /// - Returns: A `Bool` indicating if the type is compatible for conversion to the given
  /// ``ParentType``.
  public func _canBeConverted(to otherType: ParentType) -> Bool {
    switch otherType {
    case .Object(let otherType):
      return self.__typename == otherType.__typename.description

    case .Interface(let interface):
      return implements(interface)

    case .Union(let union):
      return union.possibleTypes.contains(where: { $0 == self })
    }
  }

  /// A helper function to determine if the receiver implement's a given ``Interface`` Type.
  ///
  /// - Parameter interface: An ``Interface`` Type
  /// - Returns: A `Bool` indicating if the receiver implements the given ``Interface`` Type.
  public final func implements(_ interface: Interface.Type) -> Bool {
    __implementedInterfaces?.contains(where: { $0 == interface }) ?? false
  }
}
