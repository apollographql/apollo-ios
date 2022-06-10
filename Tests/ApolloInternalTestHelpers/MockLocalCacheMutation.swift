import Foundation
import ApolloAPI

open class MockLocalCacheMutation<SelectionSet: MutableRootSelectionSet>: LocalCacheMutation {
  public typealias Data = SelectionSet

  open var variables: GraphQLOperation.Variables?

  public init() {}

}

public protocol MockMutableRootSelectionSet: MutableRootSelectionSet {}

public extension MockMutableRootSelectionSet {
  static var schema: SchemaConfiguration.Type { MockSchemaConfiguration.self }
  static var __parentType: ParentType { .Object(Object.self) }
}
