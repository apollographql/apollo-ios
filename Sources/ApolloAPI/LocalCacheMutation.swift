import Foundation

public protocol LocalCacheMutation: AnyObject, Hashable {
  static var operationType: GraphQLOperationType { get }

  var variables: GraphQLOperation.Variables? { get }

  associatedtype Data: MutableRootSelectionSet
}

public extension LocalCacheMutation {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.variables?.jsonEncodableValue?.jsonValue == rhs.variables?.jsonEncodableValue?.jsonValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(variables?.jsonEncodableValue?.jsonValue)
  }
}

public protocol MutableSelectionSet: SelectionSet {
  var data: DataDict { get set }
}

public protocol MutableRootSelectionSet: RootSelectionSet, MutableSelectionSet {}

extension MutableSelectionSet {

  @inlinable public var __typename: String {
    get { data["__typename"] }
    set { data["__typename"] = newValue }
  }

  @inlinable public subscript<T: SelectionSet>(
    asInlineFragment _: Void,
    if conditions: Selection.Conditions? = nil
  ) -> T? where T.Schema == Schema {
    get { _asInlineFragment(if: conditions) }
    _modify {
      var f: T? = _asInlineFragment(if: conditions)
      defer {
        if let newData = f?.data._data {
          data._data = newData
        }
      }
      yield &f
    }
  }

  @inlinable public subscript<T: SelectionSet>(
    asInlineFragment _: Void,
    if condition: Selection.Condition
  ) -> T? where T.Schema == Schema {
    get { self[asInlineFragment:(), if: Selection.Conditions(condition)] }
    _modify {
      yield &self[asInlineFragment:(), if: Selection.Conditions(condition)]
    }
  }

  @inlinable public subscript<T: SelectionSet>(
    asInlineFragment _: Void,
    if conditions: [Selection.Condition]
  ) -> T? where T.Schema == Schema {
    get { self[asInlineFragment:(), if: Selection.Conditions([conditions])] }
    _modify {
      yield &self[asInlineFragment:(), if: Selection.Conditions([conditions])]
    }
  }
}
