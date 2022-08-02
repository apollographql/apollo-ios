import Foundation
import ApolloAPI

open class MockLocalCacheMutation<SelectionSet: MutableRootSelectionSet>: LocalCacheMutation {
  open class var operationType: GraphQLOperationType { .query }

  public typealias Data = SelectionSet

  open var variables: GraphQLOperation.Variables?

  public init() {}

}

open class MockLocalCacheMutationFromMutation<SelectionSet: MutableRootSelectionSet>:
  MockLocalCacheMutation<SelectionSet> {
  override open class var operationType: GraphQLOperationType { .mutation }
}

open class MockLocalCacheMutationFromSubscription<SelectionSet: MutableRootSelectionSet>:
  MockLocalCacheMutation<SelectionSet> {
  override open class var operationType: GraphQLOperationType { .subscription }
}

public protocol MockMutableRootSelectionSet: MutableRootSelectionSet
where Schema == MockSchemaConfiguration {}

public extension MockMutableRootSelectionSet {
  static var __parentType: ParentType { .Object(Object.mock) }

  init() {
    self.init(data: DataDict([:], variables: nil))
  }
}

public protocol MockMutableInlineFragment: MutableSelectionSet, InlineFragment
where Schema == MockSchemaConfiguration {}
