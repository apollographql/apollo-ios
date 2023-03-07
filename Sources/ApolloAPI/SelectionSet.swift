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
public protocol RootSelectionSet: SelectionSet, OutputTypeConvertible { }

/// A selection set that represents an inline fragment nested inside a `RootSelectionSet`.
///
/// An `InlineFragment` can only ever exist as a nested selection set within a `RootSelectionSet`.
/// Each `InlineFragment` represents additional fields to be selected if the underlying
/// type.inclusion condition of the object data returned for the selection set is met.
///
/// An `InlineFragment` will only include the specific `selections` that should be selected for that
/// `InlineFragment`. But the code generation engine will create accessor fields for any fields
/// from the fragment's parent `RootSelectionSet` that will be selected. This includes fields from
/// the parent selection set, as well as any other child selections sets that are compatible with
/// the `InlineFragment`'s `__parentType` and the operation's inclusion condition.
public protocol InlineFragment: SelectionSet {
  associatedtype RootEntityType: RootSelectionSet
}

// MARK: - SelectionSet
public protocol SelectionSet: SelectionSetEntityValue, Hashable {
  associatedtype Schema: SchemaMetadata

  /// A type representing all of the fragments the `SelectionSet` can be converted to.
  /// Defaults to a stub type with no fragments.
  /// A `SelectionSet` with fragments should provide a type that conforms to `FragmentContainer`
  associatedtype Fragments = NoFragments

  static var __selections: [Selection] { get }

  /// The GraphQL type for the `SelectionSet`.
  ///
  /// This may be a concrete type (`Object`) or an abstract type (`Interface`, or `Union`).
  static var __parentType: ParentType { get }

  /// The data of the underlying GraphQL object represented by generated selection set.
  var __data: DataDict { get }

  /// Designated Initializer
  ///
  /// - Parameter data: The data of the underlying GraphQL object represented by generated
  /// selection set.
  init(_dataDict: DataDict)
}

extension SelectionSet {  

  @inlinable public static var __selections: [Selection] { [] }

  @inlinable public var __objectType: Object? { __data._objectType }

  @inlinable public var __typename: String { __data["__typename"] }

  /// Verifies if a `SelectionSet` may be converted to an `InlineFragment` and performs
  /// the conversion.
  ///
  /// - Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public func _asInlineFragment<T: SelectionSet>(
    if conditions: Selection.Conditions? = nil
  ) -> T? where T.Schema == Schema {
    let child: T? = _asType()

    guard let conditions = conditions else {
      return child
    }

    return conditions.evaluate(with: child?.__data._variables) ? child : nil
  }

  @usableFromInline func _asType<T: SelectionSet>() -> T? where T.Schema == Schema {
    guard let __objectType = __objectType,
          T.__parentType.canBeConverted(from: __objectType) else { return nil }

    return T.init(_dataDict: __data)
  }

  @inlinable public func _asInlineFragment<T: SelectionSet>(
    if conditions: [Selection.Condition]
  ) -> T? where T.Schema == Schema {
    _asInlineFragment(if: Selection.Conditions([conditions]))
  }

  @inlinable public func _asInlineFragment<T: SelectionSet>(
    if condition: Selection.Condition
  ) -> T? where T.Schema == Schema {
    _asInlineFragment(if: Selection.Conditions(condition))
  }

  @inlinable public func hash(into hasher: inout Hasher) {
    hasher.combine(__data)
  }

  @inlinable public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.__data == rhs.__data
  }
}

extension SelectionSet where Fragments: FragmentContainer {
  /// Contains accessors for all of the fragments the `SelectionSet` can be converted to.
  public var fragments: Fragments { Fragments(data: __data) }
}

extension InlineFragment {
  @inlinable public var asRootEntityType: RootEntityType {
    RootEntityType.init(_dataDict: __data)
  }
}
