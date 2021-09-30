@testable import ApolloCodegenLib

public extension CompilationResult.OperationDefinition {

  class func mock(usingFragments: [CompilationResult.FragmentDefinition] = []) -> Self {
    let mock = Self.emptyMockObject()
#warning("TODO: Implement - How does code gen engine compute the used fragments?")
    return mock
  }
}

public extension CompilationResult.SelectionSet {

  class func mock(
    parentType: GraphQLCompositeType = GraphQLObjectType.mock(),
    selections: [CompilationResult.Selection] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.parentType = parentType
    mock.selections = selections
    return mock
  }
}

public extension CompilationResult.Field {

  class func mock(
    name: String = "",
    alias: String? = nil,
    arguments: [CompilationResult.Argument]? = nil,
    type: GraphQLType = .named(GraphQLObjectType.mock()),
    selectionSet: CompilationResult.SelectionSet = .mock()
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.alias = alias
    mock.arguments = arguments
    mock.type = type
    mock.selectionSet = selectionSet
    return mock
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

  class func mock(_ name: String = "NameFragment") -> Self {
    let mock = Self.emptyMockObject()
    mock.source = Self.mockDefinition(name: name)
    return mock
  }
}
