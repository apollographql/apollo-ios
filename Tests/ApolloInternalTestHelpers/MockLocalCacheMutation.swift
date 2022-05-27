import Foundation
import ApolloAPI

@dynamicMemberLookup
open class MockMutableSelectionSet: MutableRootSelectionSet {
  open class var schema: SchemaConfiguration.Type { MockSchemaConfiguration.self }
  open class var selections: [Selection] { [] }
  open class var __parentType: ParentType { .Object(Object.self) }

  public var data: DataDict = DataDict([:], variables: nil)

  public required init(data: DataDict) {
    self.data = data
  }

  public subscript<T: AnyScalarType & Hashable>(dynamicMember key: String) -> T? {
    get { data[key] }
    set { data[key] = newValue }
  }

  public subscript<T: MockMutableSelectionSet>(dynamicMember key: String) -> T? {
    get { data[key] }
    set { data[key] = newValue }
  }
}

open class MockLocalCacheMutation<SelectionSet: MutableRootSelectionSet>: LocalCacheMutation {
  public typealias Data = SelectionSet

  open var variables: GraphQLOperation.Variables?

  public init() {}

}
