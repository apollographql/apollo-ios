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

public protocol MutableRootSelectionSet: RootSelectionSet, MutableSelectionSet {}

extension MutableSelectionSet {

  @inlinable public var __typename: String {
    get { data["__typename"] }
    set { data["__typename"] = newValue }
  }

}
