// MARK: - Fragment

/// A protocol representing a fragment that a `SelectionSet` object may be converted to.
///
/// A `SelectionSet` that conforms to `HasFragments` can be converted to
/// any `Fragment` included in it's `Fragments` object via its `fragments` property.
///
/// - SeeAlso: `HasFragments`, `ToFragments`
public protocol Fragment: AnySelectionSet {
  static var fragmentDefinition: String { get }
}

// MARK: - HasFragments

/// A protocol that a `ResponseObject` that contains fragments should conform to.
public protocol HasFragments: AnySelectionSet {

  /// A type representing all of the fragments contained on the `SelectionSet`.
  associatedtype Fragments: FragmentContainer
}

public extension HasFragments {
  /// A `FieldData` object that contains accessors for all of the fragments
  /// the object can be converted to.
  var fragments: Fragments { Fragments(data: data) }
}

public protocol FragmentContainer {
  var data: DataDict { get }

  init(data: DataDict)
}

public extension FragmentContainer {

  /// Converts a `SelectionSet` to a `Fragment` given a generic fragment type.
  ///
  /// - Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  #warning("TODO: Audit all _ prefixed things to see if they should be available using ApolloExtension.")
  func _toFragment<T: Fragment>() -> T {
    return T.init(data: data)
  }
}
