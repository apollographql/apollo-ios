import Foundation

public protocol LocalCacheMutation: AnyObject, Hashable {
  static var operationType: GraphQLOperationType { get }

  var variables: GraphQLOperation.Variables? { get }

  associatedtype Data: MutableRootSelectionSet
}

public extension LocalCacheMutation {
  var variables: GraphQLOperation.Variables? {
    return nil
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(variables?.jsonEncodableValue?.jsonValue)
  }

  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.variables?.jsonEncodableValue?.jsonValue == rhs.variables?.jsonEncodableValue?.jsonValue
  }
}

public protocol MutableSelectionSet: SelectionSet {
  var data: DataDict { get set }
}

public extension MutableSelectionSet {
  @inlinable var __typename: String {
    get { data["__typename"] }
    set { data["__typename"] = newValue }
  }
}

public extension MutableSelectionSet where Fragments: FragmentContainer {
  @inlinable var fragments: Fragments {
    get { Self.Fragments(data: data) }
    _modify {
      var f = Self.Fragments(data: data)
      yield &f
      self.data._data = f.data._data
    }
    @available(*, unavailable, message: "mutate properties of the fragment instead.")
    set { preconditionFailure("") }
  }
}

public protocol MutableRootSelectionSet: RootSelectionSet, MutableSelectionSet {}

#warning("!! TODO: Conditionally included fragments are optional but will always be created and crash on field access !!")
