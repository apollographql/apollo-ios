@testable import ApolloCodegenLib

extension ASTField {
  public static func mock(
    _ name: String = "",
    alias: String? = nil,
    arguments: [CompilationResult.Argument]? = nil,
    type: GraphQLType = .named(GraphQLObjectType.mock("MOCK")),
    selectionSet: CompilationResult.SelectionSet = .mock()
  ) -> Self {
    let mockField = CompilationResult.Field.mock(
      name,
      alias: alias,
      arguments: arguments,
      type: type,
      selectionSet: selectionSet)

    return ASTField(mockField, enclosingEntityMergedSelectionBuilder: nil)
  }

  public static func mock(
    _ name: String = "",
    alias: String? = nil,
    arguments: [CompilationResult.Argument]? = nil,
    type: GraphQLScalarType,
    selectionSet: CompilationResult.SelectionSet = .mock()
  ) -> Self {
    let mockField = CompilationResult.Field.mock(
      name,
      alias: alias,
      arguments: arguments,
      type: .named(type),
      selectionSet: selectionSet)

    return ASTField(mockField, enclosingEntityMergedSelectionBuilder: nil)
  }
}
