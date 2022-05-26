import Foundation
import ApolloAPI

open class MockMutableSelectionSet: AbstractMockSelectionSet, MutableRootSelectionSet { }

open class MockLocalCacheMutation<SelectionSet: MutableRootSelectionSet>: LocalCacheMutation {
  public typealias Data = SelectionSet

  open var variables: GraphQLOperation.Variables?

  public init() {}

}
