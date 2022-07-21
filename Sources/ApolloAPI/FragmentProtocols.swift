// MARK: - Fragment

/// A protocol representing a fragment that a ``SelectionSet`` object may be converted to.
///
/// A ``SelectionSet`` can be converted to any ``Fragment`` included in it's
/// `Fragments` object via its ``SelectionSet/fragments-swift.property`` property.
public protocol Fragment: AnySelectionSet {
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
  /// - Parameter data: The data of the underlying GraphQL object represented by the parent ``SelectionSet``
  init(data: DataDict)
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
    return T.init(data: __data)
  }

  /// Converts a ``SelectionSet`` to a ``Fragment`` given a generic fragment type if the given
  /// `@include/@skip` conditions are met.
  ///
  /// For more information on `@include/@skip` conditions, see ``Selection/Condition``
  ///
  /// > Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// - Parameter conditions: The `@include/@skip` conditions to evaluate prior to
  /// fragment conversion.
  /// - Returns: The ``Fragment`` the ``SelectionSet`` has been converted to, or `nil` if
  /// the `@include/@skip` conditions are not met.
  @inlinable public func _toFragment<T: Fragment>(
    if conditions: Selection.Conditions? = nil
  ) -> T? {
    guard let conditions = conditions else {
      return _convertToFragment()
    }

    return conditions.evaluate(with: __data._variables) ? _convertToFragment() : nil
  }

  /// Converts a ``SelectionSet`` to a ``Fragment`` given a generic fragment type if the given
  /// `@include/@skip` conditions are met.
  ///
  /// For more information on `@include/@skip` conditions, see ``Selection/Condition``
  ///
  /// > Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// - Parameter conditions: The `@include/@skip` conditions to evaluate prior to
  /// fragment conversion.
  /// - Returns: The ``Fragment`` the ``SelectionSet`` has been converted to, or `nil` if
  /// the `@include/@skip` conditions are not met.
  @inlinable public func _toFragment<T: Fragment>(
    if conditions: [Selection.Condition]
  ) -> T? {
    return _toFragment(if: Selection.Conditions([conditions]))
  }

  /// Converts a ``SelectionSet`` to a ``Fragment`` given a generic fragment type if the given
  /// `@include/@skip` condition is met.
  ///
  /// For more information on `@include/@skip` conditions, see ``Selection/Condition``
  ///
  /// > Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// - Parameter conditions: The `@include/@skip` condition to evaluate prior to
  /// fragment conversion.
  /// - Returns: The ``Fragment`` the ``SelectionSet`` has been converted to, or `nil` if
  /// the `@include/@skip` condition is not met.
  @inlinable public func _toFragment<T: Fragment>(
    if condition: Selection.Condition
  ) -> T? {
    return _toFragment(if: Selection.Conditions(condition))
  }
}

/// A ``FragmentContainer`` to be used by ``SelectionSet``s that have no fragments.
/// This is the default ``FragmentContainer`` for a ``SelectionSet`` that does not specify a
/// `Fragments` type.
public enum NoFragments {}
