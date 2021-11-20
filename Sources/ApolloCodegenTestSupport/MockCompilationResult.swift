@testable import ApolloCodegenLib

public extension CompilationResult {
  class func mock(referencedTypes: ReferencedTypes? = nil) -> Self {
    let mock = Self.emptyMockObject()
    mock.referencedTypes = referencedTypes ?? ReferencedTypes([])
    return mock
  }
}

public extension CompilationResult.OperationDefinition {

  class func mock(usingFragments: [CompilationResult.FragmentDefinition] = []) -> Self {
    let mock = Self.emptyMockObject()
#warning("TODO: Implement - How does code gen engine compute the used fragments?")
    return mock
  }

  class func mock(
    type: CompilationResult.OperationType = .query,
    selections: [CompilationResult.Selection]
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.operationType = type
    mock.rootType = type.mockRootType()
    mock.selectionSet = CompilationResult.SelectionSet.mock(
      parentType: mock.rootType,
      selections: selections
    )
    return mock
  }
}

public extension CompilationResult.OperationType {
  public func mockRootType() -> GraphQLCompositeType {
    GraphQLObjectType.mock(rawValue.uppercased())
  }
}

public extension CompilationResult.SelectionSet {

  class func mock(
    parentType: GraphQLCompositeType = GraphQLObjectType.mock(),
    selections: [CompilationResult.Selection] = []
  ) -> Self {
    let mock = Self(nil)
    mock.parentType = parentType
    mock.selections = selections
    return mock
  }
}

public extension CompilationResult.Field {

  class func mock(
    _ name: String = "",
    alias: String? = nil,
    arguments: [CompilationResult.Argument]? = nil,
    type: GraphQLType = .entity(GraphQLObjectType.mock("MOCK")),
    selectionSet: CompilationResult.SelectionSet = .mock()
  ) -> Self {
    let mock = Self(nil)
    mock.name = name
    mock.alias = alias
    mock.arguments = arguments
    mock.type = type
    mock.selectionSet = selectionSet
    return mock
  }

  class func mock(
    _ name: String = "",
    alias: String? = nil,
    arguments: [CompilationResult.Argument]? = nil,
    type: GraphQLScalarType
  ) -> Self {
    Self.mock(
      name,
      alias: alias,
      arguments: arguments,
      type: .scalar(type)
    )
  }
}

public extension CompilationResult.FragmentDefinition {
  private class func mockDefinition(name: String) -> String {
    return """
    fragment \(name) on Person {
      name
    }
    """
  }

  class func mock(
    _ name: String = "NameFragment",
    type: GraphQLCompositeType = .emptyMockObject(),
    selections: [CompilationResult.Selection] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    mock.selectionSet = .mock(parentType: type, selections: selections)
    mock.source = Self.mockDefinition(name: name)
    return mock
  }
}
