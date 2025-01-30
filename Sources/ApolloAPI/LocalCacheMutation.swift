public protocol LocalCacheMutation: AnyObject, Hashable {
  static var operationType: GraphQLOperationType { get }

  var __variables: GraphQLOperation.Variables? { get }

  associatedtype Data: MutableRootSelectionSet
}

public extension LocalCacheMutation {
  var __variables: GraphQLOperation.Variables? {
    return nil
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(__variables?._jsonEncodableValue?._jsonValue)
  }

  static func ==(lhs: Self, rhs: Self) -> Bool {
    AnySendableHashable.equatableCheck(
      lhs.__variables?._jsonEncodableValue?._jsonValue,
      rhs.__variables?._jsonEncodableValue?._jsonValue
    )
  }
}

public protocol MutableSelectionSet: SelectionSet {
  var __data: DataDict { get set }
}

public extension MutableSelectionSet {
  @inlinable var __typename: String? {
    get { __data["__typename"] }
    set { __data["__typename"] = newValue }
  }
}

public extension MutableSelectionSet where Fragments: FragmentContainer {
  @inlinable var fragments: Fragments {
    get { Self.Fragments(_dataDict: __data) }
    _modify {
      var f = Self.Fragments(_dataDict: __data)
      yield &f
      self.__data._data = f.__data._data
    }
  }
}

public extension MutableSelectionSet where Self: InlineFragment {

  /// Function for mutating a conditional inline fragment on a mutable selection set.
  ///
  /// This function is the only supported way to mutate an inline fragment. Because setting the
  /// value for an inline fragment that was not already present would result in fatal data
  /// inconsistencies, inline fragments properties are get-only. However, mutating the properties of
  /// an inline fragment that has been fulfilled is allowed. This function enables the described
  /// functionality by checking if the fragment is fulfilled and, if so, calling the mutation body.
  ///
  /// - Parameters:
  ///   - keyPath: The `KeyPath` to the inline fragment to mutate the properties of
  ///   - transform: A closure used to apply mutations to the inline fragment's properties.
  /// - Returns: A `Bool` indicating if the fragment was fulfilled.
  ///   If this returns `false`, the `transform` block will not be called.
  @discardableResult
  mutating func mutateIfFulfilled<T: InlineFragment>(
    _ keyPath: KeyPath<Self, T?>,
    _ transform: (inout T) -> Void
  ) -> Bool where T.RootEntityType == Self.RootEntityType {
    guard var fragment = self[keyPath: keyPath] else {
      return false
    }

    transform(&fragment)
    self.__data = fragment.__data
    return true
  }
}

public protocol MutableRootSelectionSet: RootSelectionSet, MutableSelectionSet {}

public extension MutableRootSelectionSet {
  
  /// Function for mutating a conditional inline fragment on a mutable selection set.
  ///
  /// This function is the only supported way to mutate an inline fragment. Because setting the
  /// value for an inline fragment that was not already present would result in fatal data
  /// inconsistencies, inline fragments properties are get-only. However, mutating the properties of
  /// an inline fragment that has been fulfilled is allowed. This function enables the described
  /// functionality by checking if the fragment is fulfilled and, if so, calling the mutation body.
  ///
  /// - Parameters:
  ///   - keyPath: The `KeyPath` to the inline fragment to mutate the properties of
  ///   - transform: A closure used to apply mutations to the inline fragment's properties.
  /// - Returns: A `Bool` indicating if the fragment was fulfilled.
  ///   If this returns `false`, the `transform` block will not be called.
  @discardableResult
  mutating func mutateIfFulfilled<T: InlineFragment>(
    _ keyPath: KeyPath<Self, T?>,
    _ transform: (inout T) -> Void
  ) -> Bool where T.RootEntityType == Self {
    guard var fragment = self[keyPath: keyPath] else {
      return false
    }

    transform(&fragment)
    self.__data = fragment.__data
    return true
  }
}
