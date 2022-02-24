// MARK: - Type Erased SelectionSets

public protocol AnySelectionSet {
  static var schema: SchemaConfiguration.Type { get }

  static var selections: [Selection] { get }

  /// The GraphQL type for the `SelectionSet`.
  ///
  /// This may be a concrete type (`Object`) or an abstract type (`Interface`, or `Union`).
  static var __parentType: ParentType { get }

  var data: DataDict { get }

  init(data: DataDict)
}

public extension AnySelectionSet {
  static var selections: [Selection] { [] }
}

/// A selection set that represents the root selections on its `__parentType`. Nested selection
/// sets for type cases are not `RootSelectionSet`s.
///
/// While a `TypeCase` only provides the additional selections that should be selected for its
/// specific type, a `RootSelectionSet` guarantees that all fields for itself and its nested type
/// cases are selected.
///
/// When considering a specific `TypeCase`, all fields will be selected either by the root selection
/// set, a fragment spread, the type case itself, or another compatible `TypeCase` on the root
/// selection set.
///
/// This is why only a `RootSelectionSet` can be executed by a `GraphQLExecutor`. Executing a
/// non-root selection set would result in fields from the root selection set not being collected
/// into the `ResponseDict` for the `SelectionSet`'s data.
public protocol RootSelectionSet: AnySelectionSet, OutputTypeConvertible { }

/// A selection set that represents a more specific type nested inside a `RootSelectionSet`.
///
/// A `TypeCase` can only ever exist as a nested selection set within a `RootSelectionSet`.
/// Each `TypeCase` represents additional fields to be selected if the underlying type of the
/// object data returned for the selection set at runtime is compatible with the type case's
/// `__parentType`.
///
/// A `TypeCase` will only include the specific `selections` that should be selected for that
/// `TypeCase`. But the code generation engine will create accessor fields for any fields from the
/// type case's parent `RootSelectionSet` that will be selected. This includes fields from the
/// parent selection set, as well as any other child selections sets that are compatible with the
/// `TypeCase`'s `__parentType`.
public protocol TypeCase: AnySelectionSet { }

// MARK: - SelectionSet
public protocol SelectionSet: AnySelectionSet {
  associatedtype Schema: SchemaConfiguration

  /// A type representing all of the fragments the `SelectionSet` can be converted to.
  /// Defaults to a stub type with no fragments.
  /// A `SelectionSet` with fragments should provide a type that conforms to `FragmentContainer`
  associatedtype Fragments = NoFragments
}

extension SelectionSet {

  public static var schema: SchemaConfiguration.Type { Schema.self }

  var __objectType: Object.Type? { Schema.objectType(forTypename: __typename) }

  @inlinable var __typename: String { data["__typename"] }

  /// Verifies if a `SelectionSet` may be converted to a different `SelectionSet` and performs
  /// the conversion.
  ///
  /// - Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  public func _asType<T: SelectionSet>() -> T? where T.Schema == Schema {
    guard let __objectType = __objectType,
          __objectType._canBeConverted(to: T.__parentType) else { return nil }

    return T.init(data: data)
  }
}

extension SelectionSet where Fragments: FragmentContainer {
  /// Contains accessors for all of the fragments the `SelectionSet` can be converted to.
  public var fragments: Fragments { Fragments(data: data) }
}
