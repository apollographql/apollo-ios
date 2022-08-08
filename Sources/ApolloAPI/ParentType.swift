/// A protocol for a type that represents the `__parentType` of a ``SelectionSet``.
///
/// A ``SelectionSet``'s `__parentType` is the type from the schema that the selection set is
/// selected against. This type can be an ``Object``, ``Interface``, or ``Union``.
public protocol ParentType {
  /// A helper function to determine if an ``Object`` of the given type can be converted to
  /// the receiver type.
  ///
  /// A type can be converted to an ``Interface`` type if and only if the type implements
  /// the interface.
  /// (ie. The ``Interface`` is contained in the ``Object``'s ``Object/implementedInterfaces``.)
  ///
  /// A type can be converted to a ``Union`` type if and only if the union includes the type.
  /// (ie. The ``Object`` Type is contained in the ``Union``'s ``Union/possibleTypes``.)
  ///
  /// - Parameter objectType: An ``Object`` type to determine conversion compatibility for
  /// - Returns: A `Bool` indicating if the type is compatible for conversion to the receiver type
  @inlinable func canBeConverted(from objectType: Object) -> Bool
}

extension Object: ParentType {
  @inlinable public func canBeConverted(from objectType: Object) -> Bool {
    objectType.typename == self.typename
  }
}

extension Interface: ParentType {
  @inlinable public func canBeConverted(from objectType: Object) -> Bool {
    objectType.implements(self)
  }
}

extension Union: ParentType {
  @inlinable public func canBeConverted(from objectType: Object) -> Bool {
    possibleTypes.contains(where: { $0 == objectType })
  }
}
