import Foundation

public protocol LocalCacheMutation: AnyObject, Hashable {
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

public protocol MutableSelectionSet: AnySelectionSet {}

public protocol MutableRootSelectionSet: RootSelectionSet, MutableSelectionSet {}
