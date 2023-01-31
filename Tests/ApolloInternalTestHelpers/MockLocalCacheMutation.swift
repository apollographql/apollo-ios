import Foundation
import ApolloAPI

open class MockLocalCacheMutation<SelectionSet: MutableRootSelectionSet>: LocalCacheMutation {
  open class var operationType: GraphQLOperationType { .query }

  public typealias Data = SelectionSet

  open var __variables: GraphQLOperation.Variables?

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
where Schema == MockSchemaMetadata {}

public extension MockMutableRootSelectionSet {
  static var __parentType: ParentType { Object.mock }

  init() {
    self.init(data: .empty())
  }
}

public protocol MockMutableInlineFragment: MutableSelectionSet, InlineFragment
where Schema == MockSchemaMetadata {}
