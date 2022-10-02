import Foundation

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
    lhs.__variables?._jsonEncodableValue?._jsonValue == rhs.__variables?._jsonEncodableValue?._jsonValue
  }
}

public protocol MutableSelectionSet: SelectionSet {
  var __data: DataDict { get set }
}

public extension MutableSelectionSet {
  @inlinable var __typename: String {
    get { __data["__typename"] }
    set { __data["__typename"] = newValue }
  }
}

public extension MutableSelectionSet where Fragments: FragmentContainer {
  @inlinable var fragments: Fragments {
    get { Self.Fragments(data: __data) }
    _modify {
      var f = Self.Fragments(data: __data)
      yield &f
      self.__data._data = f.__data._data
    }
    @available(*, unavailable, message: "mutate properties of the fragment instead.")
    set { preconditionFailure("") }
  }
}

public protocol MutableRootSelectionSet: RootSelectionSet, MutableSelectionSet {}
