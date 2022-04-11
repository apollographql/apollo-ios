@testable import ApolloAPI

open class MockOperation<SelectionSet: RootSelectionSet>: GraphQLOperation {
  public typealias Data = SelectionSet

  public let operationType: GraphQLOperationType

  public var operationName: String = "MockOperationName"
  public var document: DocumentType = .notPersisted(definition: .init("Mock Operation Definition"))

  open var variables: Variables?

  public init(type: GraphQLOperationType = .query) {
    self.operationType = type
  }

  public static func mock(
    type: GraphQLOperationType = .query
  ) -> MockOperation<MockSelectionSet> where SelectionSet == MockSelectionSet {
    MockOperation<MockSelectionSet>(type: type)
  }

}

open class MockQuery<SelectionSet: RootSelectionSet>: MockOperation<SelectionSet>, GraphQLQuery {
  public init() {
    super.init(type: .query)
  }

  public static func mock() -> MockQuery<MockSelectionSet> where SelectionSet == MockSelectionSet {
    MockQuery<MockSelectionSet>()
  }
}

open class MockMutation<SelectionSet: RootSelectionSet>: MockOperation<SelectionSet>, GraphQLMutation {
  public init() {
    super.init(type: .mutation)
  }

  public static func mock() -> MockMutation<MockSelectionSet> where SelectionSet == MockSelectionSet {
    MockMutation<MockSelectionSet>()
  }
}

open class MockSubscription<SelectionSet: RootSelectionSet>: MockOperation<SelectionSet>, GraphQLSubscription {
  public init() {
    super.init(type: .subscription)
  }

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

  public subscript<T: AnyScalarType>(dynamicMember key: String) -> [T]? {
    data[key]
  }

  public subscript<T: AnyScalarType>(dynamicMember key: String) -> [T?]? {
    data[key]
  }

  public subscript<T: AnyScalarType>(dynamicMember key: String) -> [[T]]? {
    data[key]
  }

  public subscript<T: AnyScalarType>(dynamicMember key: String) -> [[T?]]? {
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
