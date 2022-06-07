import Foundation
import ApolloAPI

open class MockLocalCacheMutation<SelectionSet: MutableRootSelectionSet>: LocalCacheMutation {
  public typealias Data = SelectionSet

  open var variables: GraphQLOperation.Variables?

  public init() {}

}
