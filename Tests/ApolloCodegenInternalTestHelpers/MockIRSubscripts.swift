@testable import ApolloCodegenLib

public protocol ScopeConditionalSubscriptAccessing {

  subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? { get }

}

extension ScopeConditionalSubscriptAccessing {

  public subscript(as typeCase: String) -> IR.SelectionSet? {
    guard let scope = self.scopeCondition(type: typeCase, conditions: nil) else {
      return nil
    }

    return self[scope]
  }

  public subscript(
    as typeCase: String? = nil,
    if condition: IR.InclusionCondition? = nil
  ) -> IR.SelectionSet? {
    let conditions: IR.InclusionConditions.Result?
    if let condition = condition {
      conditions = .conditional(.init(condition))
    } else {
      conditions = nil
    }

    guard let scope = self.scopeCondition(type: typeCase, conditions: conditions) else {
      return nil
    }
    return self[scope]
  }

  public subscript(
    as typeCase: String? = nil,
    if conditions: IR.InclusionConditions.Result? = nil
  ) -> IR.SelectionSet? {
    guard let scope = self.scopeCondition(type: typeCase, conditions: conditions) else {
      return nil
    }

    return self[scope]
  }

  private func scopeCondition(
    type typeCase: String?,
    conditions conditionsResult: IR.InclusionConditions.Result?
  ) -> IR.ScopeCondition? {
    let type: GraphQLCompositeType?
    if let typeCase = typeCase {
      type = GraphQLCompositeType.mock(typeCase)
    } else {
      type = nil
    }

    let conditions: IR.InclusionConditions?

    if let conditionsResult = conditionsResult {
      guard conditionsResult != .skipped else {
        return nil
      }

      conditions = conditionsResult.conditions

    } else {
      conditions = nil
    }

    return IR.ScopeCondition(type: type, conditions: conditions)
  }

}

extension IR.DirectSelections: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    inlineFragments[conditions]?.selectionSet
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    namedFragments[fragment]
  }
}

extension IR.MergedSelections: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    inlineFragments[conditions]?.selectionSet
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    namedFragments[fragment]
  }
}

extension IR.EntityTreeScopeSelections {
  public subscript(field field: String) -> IR.Field? {
    fields[field]
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    fragments[fragment]
  }
}


extension IR.Field: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    return selectionSet?[field: field]
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    return selectionSet?[conditions]
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    return selectionSet?[fragment: fragment]
  }

  public var selectionSet: IR.SelectionSet? {
    guard let entityField = self as? IR.EntityField else { return nil }
    return entityField.selectionSet as IR.SelectionSet
  }
}

extension IR.SelectionSet: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    selections[field: field]
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    selections[conditions]
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    selections[fragment: fragment]
  }
}

extension IR.SelectionSet.Selections: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    direct?.fields[field] ?? merged.fields[field]
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    return direct?.inlineFragments[conditions]?.selectionSet ??
    merged.inlineFragments[conditions]?.selectionSet
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    direct?.namedFragments[fragment] ?? merged.namedFragments[fragment]
  }
}

extension IR.Operation: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    return rootField.underlyingField.name == field ? rootField : nil
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    rootField[conditions]
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
    rootField[fragment: fragment]
  }
}

extension IR.NamedFragment: ScopeConditionalSubscriptAccessing {
  public subscript(field field: String) -> IR.Field? {
    return rootField.selectionSet[field: field]
  }

  public subscript(conditions: IR.ScopeCondition) -> IR.SelectionSet? {
    return rootField.selectionSet[conditions]
  }

  public subscript(fragment fragment: String) -> IR.NamedFragmentSpread? {
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

  public subscript(type name: String) -> GraphQLNamedType? {
    return referencedTypes.first { $0.name == name }
  }

  public subscript(operation name: String) -> CompilationResult.OperationDefinition? {
    return operations.first { $0.name == name }
  }

  public subscript(fragment name: String) -> CompilationResult.FragmentDefinition? {
    return fragments.first { $0.name == name }
  }
}
