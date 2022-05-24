@testable import ApolloAPI

open class MockOperation<SelectionSet: RootSelectionSet>: GraphQLOperation {
  public typealias Data = SelectionSet

  open class var operationType: GraphQLOperationType { .query }

  open class var operationName: String { "MockOperationName" }

  open class var document: DocumentType {
    .notPersisted(definition: .init("Mock Operation Definition"))
  }

  open var variables: Variables?

  public init() {}

}

open class MockQuery<SelectionSet: RootSelectionSet>: MockOperation<SelectionSet>, GraphQLQuery {
  public static func mock() -> MockQuery<MockSelectionSet> where SelectionSet == MockSelectionSet {
    MockQuery<MockSelectionSet>()
  }
}

open class MockMutation<SelectionSet: RootSelectionSet>: MockOperation<SelectionSet>, GraphQLMutation {

  public override class var operationType: GraphQLOperationType { .mutation }

  public static func mock() -> MockMutation<MockSelectionSet> where SelectionSet == MockSelectionSet {
    MockMutation<MockSelectionSet>()
  }
}

open class MockSubscription<SelectionSet: RootSelectionSet>: MockOperation<SelectionSet>, GraphQLSubscription {

  public override class var operationType: GraphQLOperationType { .subscription }

  public static func mock() -> MockSubscription<MockSelectionSet> where SelectionSet == MockSelectionSet {
    MockSubscription<MockSelectionSet>()
  }
}

// MARK: - MockSelectionSets

@dynamicMemberLookup
open class AbstractMockSelectionSet: AnySelectionSet {
  open class var schema: SchemaConfiguration.Type { MockSchemaConfiguration.self }
  open class var selections: [Selection] { [] }
  open class var __parentType: ParentType { .Object(Object.self) }

  public var data: DataDict = DataDict([:], variables: nil)

  public required init(data: DataDict) {
    self.data = data
  }

  public subscript<T: AnyScalarType>(dynamicMember key: String) -> T? {
    data[key]
  }

  public subscript<T: MockSelectionSet>(dynamicMember key: String) -> T? {
    data[key]
  }
}

open class MockSelectionSet: AbstractMockSelectionSet, RootSelectionSet { }

open class MockFragment: AbstractMockSelectionSet, RootSelectionSet, Fragment {
  open class var fragmentDefinition: StaticString { "" }
}

open class MockTypeCase: AbstractMockSelectionSet, InlineFragment { }
