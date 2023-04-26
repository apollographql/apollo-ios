@testable import ApolloCodegenLib

public extension CompilationResult {

  class func mock(
    rootTypes: RootTypeDefinition = RootTypeDefinition.mock()
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.rootTypes = rootTypes
    mock.referencedTypes = []
    mock.fragments = []
    mock.operations = []
    return mock
  }

}

public extension CompilationResult.RootTypeDefinition {
  
  class func mock(
    queryName: String = "Query",
    mutationName: String = "Mutation",
    subscriptionName: String = "Subscription"
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.queryType = GraphQLCompositeType.mock(queryName)
    mock.mutationType = GraphQLCompositeType.mock(mutationName)
    mock.subscriptionType = GraphQLCompositeType.mock(subscriptionName)
    return mock
  }
  
}

public extension CompilationResult.OperationDefinition {

  class func mock(
    type: CompilationResult.OperationType = .query,
    selections: [CompilationResult.Selection] = [],
    path: String = ""
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.operationType = type
    mock.rootType = type.mockRootType()
    mock.selectionSet = CompilationResult.SelectionSet(
      parentType: mock.rootType,
      selections: selections
    )
    mock.filePath = path
    return mock
  }

  class func mock(
    name: String,
    type: CompilationResult.OperationType,
    source: String
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.operationType = type
    mock.source = source

    return mock
  }
}

public extension CompilationResult.OperationType {
  func mockRootType() -> GraphQLCompositeType {
    GraphQLObjectType.mock(rawValue.uppercased())
  }
}

public extension CompilationResult.InlineFragment {

  class func mock(
    parentType: GraphQLCompositeType = GraphQLObjectType.mock(),
    inclusionConditions: [CompilationResult.InclusionCondition]? = nil,
    selections: [CompilationResult.Selection] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.selectionSet = CompilationResult.SelectionSet(
      parentType: parentType,
      selections: selections
    )
    mock.inclusionConditions = inclusionConditions
    return mock
  }
}

public extension CompilationResult.SelectionSet {

  class func mock(
    parentType: GraphQLCompositeType = GraphQLObjectType.mock(),
    selections: [CompilationResult.Selection] = []
  ) -> Self {
    Self(
      parentType: parentType,
      selections: selections
    )
  }
}

public extension CompilationResult.Field {

  class func mock(
    _ name: String = "",
    alias: String? = nil,
    arguments: [CompilationResult.Argument]? = nil,
    type: GraphQLType = .entity(GraphQLObjectType.mock("MOCK")),
    selectionSet: CompilationResult.SelectionSet = .mock(),
    deprecationReason: String? = nil
  ) -> Self {
    let mock = Self(nil)
    mock.name = name
    mock.alias = alias
    mock.arguments = arguments
    mock.type = type
    mock.selectionSet = selectionSet
    mock.directives = nil
    mock.inclusionConditions = nil
    mock.deprecationReason = deprecationReason
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
    selections: [CompilationResult.Selection] = [],
    path: String = "",
    source: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    mock.selectionSet = .mock(parentType: type, selections: selections)
    mock.source = source ?? Self.mockDefinition(name: name)
    mock.filePath = path
    return mock
  }
}

public extension CompilationResult.FragmentSpread {
  class func mock(
    _ fragment: CompilationResult.FragmentDefinition = .mock(),
    inclusionConditions: [CompilationResult.InclusionCondition]? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.fragment = fragment
    mock.inclusionConditions = inclusionConditions
    return mock
  }
}

public extension CompilationResult.Selection {
  static func fragmentSpread(
  _ fragment: CompilationResult.FragmentDefinition,
  inclusionConditions: [CompilationResult.InclusionCondition]? = nil
  ) -> CompilationResult.Selection {
    .fragmentSpread(CompilationResult.FragmentSpread.mock(
      fragment,
      inclusionConditions: inclusionConditions
    ))
  }
}


public extension CompilationResult.VariableDefinition {
  class func mock(
    _ name: String,
    type: GraphQLType,
    defaultValue: GraphQLValue?
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    mock.defaultValue = defaultValue
    return mock
  }
}

public extension CompilationResult.Directive {
  class func mock(
    _ name: String,
    arguments: [CompilationResult.Argument]? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.arguments = arguments    
    return mock
  }
}
