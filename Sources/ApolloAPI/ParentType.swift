#warning("TODO: Documentation audit")
public protocol ParentType {
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
  @inlinable func _canBeConverted(from objectType: Object) -> Bool
}

extension Object: ParentType {
  @inlinable public func _canBeConverted(from objectType: Object) -> Bool {
    objectType.typename == self.typename
  }
}

extension Interface: ParentType {
  @inlinable public func _canBeConverted(from objectType: Object) -> Bool {
    objectType.implements(self)
  }
}

extension Union: ParentType {
  @inlinable public func _canBeConverted(from objectType: Object) -> Bool {
    possibleTypes.contains(where: { $0 == objectType })
  }
}
