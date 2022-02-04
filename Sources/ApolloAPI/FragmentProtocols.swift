// MARK: - Fragment

/// A protocol representing a fragment that a `SelectionSet` object may be converted to.
///
/// A `SelectionSet` can be converted to any `Fragment` included in it's `Fragments` object via
/// its `fragments` property.
public protocol Fragment: AnySelectionSet {
  static var fragmentDefinition: StaticString { get }
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
  func _toFragment<T: Fragment>() -> T {
    return T.init(data: data)
  }
}

/// A `FragmentContainer` to be used by `SelectionSet`s that have no fragments.
/// This is the default `FragmentContainer` for a `SelectionSet` that does not specify a
/// `Fragments` type.
public enum NoFragments {}
