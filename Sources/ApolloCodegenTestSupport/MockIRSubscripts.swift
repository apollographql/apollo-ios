@testable import ApolloCodegenLib

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
    return selectionSet?.mergedSelections.fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    return selectionSet?.mergedSelections.typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    return selectionSet?.mergedSelections.fragments[fragment]
  }

  public var selectionSet: IR.SelectionSet? {
    guard let entityField = self as? IR.EntityField else { return nil }
    return entityField.selectionSet as IR.SelectionSet
  }
}

extension IR.SelectionSet {
  public subscript(field field: String) -> IR.Field? {
    mergedSelections.fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    mergedSelections.typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    mergedSelections.fragments[fragment]
  }
}

extension IR.Operation {
  public subscript(field field: String) -> IR.Field? {
    return rootField.underlyingField.name == field ? rootField : nil
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    rootField.selectionSet.mergedSelections.typeCases[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    rootField.selectionSet.mergedSelections.fragments[fragment]
  }
}

extension CompilationResult {
  public subscript(object name: String) -> GraphQLObjectType? {
    return referencedTypes.objects.first { $0.name == name }
  }

  public subscript(interface name: String) -> GraphQLInterfaceType? {
    return referencedTypes.interfaces.first { $0.name == name }
  }

  public subscript(union name: String) -> GraphQLUnionType? {
    return referencedTypes.unions.first { $0.name == name }
  }

  public subscript(scalar name: String) -> GraphQLScalarType? {
    return referencedTypes.scalars.first { $0.name == name }
  }

  public subscript(fragment name: String) -> FragmentDefinition? {
    return fragments.first { $0.name == name }
  }
}
