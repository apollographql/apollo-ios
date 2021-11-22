@testable import ApolloCodegenLib

//extension IR.Field {
//  public static func mock(
//    _ name: String = "",
//    alias: String? = nil,
//    arguments: [CompilationResult.Argument]? = nil,
//    type: GraphQLCompositeType = GraphQLObjectType.mock("MOCK"),
//    selectionSet: CompilationResult.SelectionSet = .mock()
//  ) -> Self {
//    let mockField = CompilationResult.Field.mock(
//      name,
//      alias: alias,
//      arguments: arguments,
//      type: type,
//      selectionSet: selectionSet)
//
//    return IR.EntityField(mockField, selectionSet: selectionSet)
//  }
//
//  public static func mock(
//    _ name: String = "",
//    alias: String? = nil,
//    arguments: [CompilationResult.Argument]? = nil,
//    type: GraphQLScalarType,
//    selectionSet: CompilationResult.SelectionSet = .mock()
//  ) -> Self {
//    let mockField = CompilationResult.Field.mock(
//      name,
//      alias: alias,
//      arguments: arguments,
//      type: .scalar(type),
//      selectionSet: selectionSet)
//
//    return IR.Field(mockField, enclosingEntityMergedSelectionBuilder: nil)
//  }
//}
//

extension IR.SortedSelections {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    fragments[fragment]
  }
}

extension IR.Field {
  public subscript(field field: String) -> IR.Field? {
    return selectionSet?.selections.fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    return selectionSet?.selections.typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    return selectionSet?.selections.fragments[fragment]
  }

  public var selectionSet: IR.SelectionSet? {
    guard let entityField = self as? IR.EntityField else { return nil }
    return entityField.selectionSet as IR.SelectionSet
  }
}

extension IR.SelectionSet {
  public subscript(field field: String) -> IR.Field? {
    selections.fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    selections.typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    selections.fragments[fragment]
  }
}

extension IR.Operation {
  public subscript(field field: String) -> IR.Field? {
    rootField.selectionSet.selections.fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    rootField.selectionSet.selections.typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    rootField.selectionSet.selections.fragments[fragment]
  }
}
