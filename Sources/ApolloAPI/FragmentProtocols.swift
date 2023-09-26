// MARK: - Fragment

/// A protocol representing a fragment that a ``SelectionSet`` object may be converted to.
///
/// A ``SelectionSet`` can be converted to any ``Fragment`` included in it's
/// `Fragments` object via its ``SelectionSet/fragments-swift.property`` property.
public protocol Fragment: SelectionSet, Deferrable {
  /// The definition of the fragment in GraphQL syntax.
  static var fragmentDefinition: StaticString { get }
}

/// A protocol representing a container for the fragments on a generated ``SelectionSet``.
///
/// A generated ``FragmentContainer`` includes generated properties for converting the
/// ``SelectionSet`` into any generated ``Fragment`` that it includes.
///
/// # Code Generation
///
/// The ``FragmentContainer`` protocol is only conformed to by generated `Fragments` structs.
/// Given a query:
/// ```graphql
/// fragment FragmentA on Animal {
///   species
/// }
///
/// query {
///   animals {
///    ...FragmentA
///   }
/// }
/// ```
/// The generated `Animal` ``SelectionSet`` will include the ``FragmentContainer``:
/// ```swift
/// public struct Animal: API.SelectionSet {
///   // ...
///   public struct Fragments: FragmentContainer {
///     public let __data: DataDict
///     public init(data: DataDict) { __data = data }
///
///     public var fragmentA: FragmentA { _toFragment() }
///   }
/// }
/// ```
///
/// # Converting a SelectionSet to a Fragment
///
/// With the generated code above, you can conver the `Animal` ``SelectionSet`` to the generated
/// `FragmentA` ``Fragment``:
/// ```swift
/// let fragmentA: FragmentA = animal.fragments.fragmentA
/// ```
public protocol FragmentContainer {
  /// The data of the underlying GraphQL object represented by the parent ``SelectionSet``
  var __data: DataDict { get }

  /// Designated Initializer
  /// - Parameter dataDict: The data of the underlying GraphQL object represented by the parent ``SelectionSet``
  init(_dataDict: DataDict)
}

extension FragmentContainer {

  /// Converts a ``SelectionSet`` to a ``Fragment`` given a generic fragment type.
  ///
  /// > Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// - Returns: The ``Fragment`` the ``SelectionSet`` has been converted to
  @inlinable public func _toFragment<T: Fragment>() -> T {
    _convertToFragment()
  }

  @usableFromInline func _convertToFragment<T: Fragment>()-> T {
    return T.init(_dataDict: __data)
  }

  /// Converts a ``SelectionSet`` to a ``Fragment`` given a generic fragment type if the fragment
  /// was fulfilled.
  ///
  /// A fragment may not be fulfilled if it is condtionally included useing an `@include/@skip`
  /// directive. For more information on `@include/@skip` conditions, see ``Selection/Conditions``
  ///
  /// > Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// - Returns: The ``Fragment`` the ``SelectionSet`` has been converted to, or `nil` if the
  /// fragment was not fulfilled.
  @inlinable public func _toFragment<T: Fragment>() -> T? {
    guard __data.fragmentIsFulfilled(T.self) else { return nil }
    return T.init(_dataDict: __data)
  }

}

/// A ``FragmentContainer`` to be used by ``SelectionSet``s that have no fragments.
/// This is the default ``FragmentContainer`` for a ``SelectionSet`` that does not specify a
/// `Fragments` type.
public enum NoFragments {}
