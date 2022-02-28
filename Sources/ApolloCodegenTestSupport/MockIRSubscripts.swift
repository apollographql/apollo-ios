@testable import ApolloCodegenLib

extension IR.DirectSelections {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    conditionalSelectionSets[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    fragments[fragment]
  }
}

extension IR.MergedSelections {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    conditionalSelectionSets[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    fragments[fragment]
  }
}


extension IR.EntityTreeScopeSelections {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    fragments[fragment]
  }
}


extension IR.Field {
  public subscript(field field: String) -> IR.Field? {
    return selectionSet?[field: field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    return selectionSet?[as: typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    return selectionSet?[fragment: fragment]
  }

  public var selectionSet: IR.SelectionSet? {
    guard let entityField = self as? IR.EntityField else { return nil }
    return entityField.selectionSet as IR.SelectionSet
  }
}

extension IR.SelectionSet {
  public subscript(field field: String) -> IR.Field? {
    selections[field: field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    selections[as: typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    selections[fragment: fragment]
  }
}

extension IR.SelectionSet.Selections {
  public subscript(field field: String) -> IR.Field? {
    direct?.fields[field] ?? merged.fields[field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    direct?.conditionalSelectionSets[typeCase] ?? merged.conditionalSelectionSets[typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    direct?.fragments[fragment] ?? merged.fragments[fragment]
  }
}

extension IR.Operation {
  public subscript(field field: String) -> IR.Field? {
    return rootField.underlyingField.name == field ? rootField : nil
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    rootField[as: typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    rootField[fragment: fragment]
  }
}

extension IR.NamedFragment {
  public subscript(field field: String) -> IR.Field? {
    return rootField.selectionSet[field: field]
  }

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    return rootField.selectionSet[as: typeCase]
  }

  public subscript(fragment fragment: String) -> IR.FragmentSpread? {
    rootField.selectionSet[fragment: fragment]
  }
}

extension IR.Schema {
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

  public subscript(enum name: String) -> GraphQLEnumType? {
    return referencedTypes.enums.first { $0.name == name }
  }

  public subscript(inputObject name: String) -> GraphQLInputObjectType? {
    return referencedTypes.inputObjects.first { $0.name == name }
  }
}

extension CompilationResult {

  public subscript(operation name: String) -> CompilationResult.OperationDefinition? {
    return operations.first { $0.name == name }
  }

  public subscript(fragment name: String) -> CompilationResult.FragmentDefinition? {
    return fragments.first { $0.name == name }
  }
}
