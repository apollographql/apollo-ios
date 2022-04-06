import ApolloUtils
import InflectorKit

struct SelectionSetTemplate {

  let schema: IR.Schema
  private let nameCache = SelectionSetNameCache()

  // MARK: - Operation
  func render(for operation: IR.Operation) -> String {
    TemplateString(
    """
    public struct Data: \(schema.name).SelectionSet {
      \(BodyTemplate(operation.rootField.selectionSet))
    }
    """
    ).description
  }

  // MARK: - Field
  func render(field: IR.EntityField) -> String {
    TemplateString(
    """
    \(SelectionSetNameDocumentation(field.selectionSet))
    public struct \(field.formattedFieldName): \(schema.name).SelectionSet {
      \(BodyTemplate(field.selectionSet))
    }
    """
    ).description
  }

  // MARK: - Type Case
  func render(typeCase: IR.SelectionSet) -> String {
    TemplateString(
    """
    \(SelectionSetNameDocumentation(typeCase))
    public struct As\(typeCase.renderedTypeName): \(schema.name).TypeCase {
      \(BodyTemplate(typeCase))
    }
    """
    ).description
  }

  // MARK: - Selection Set Name Documentation
  func SelectionSetNameDocumentation(_ selectionSet: IR.SelectionSet) -> TemplateString {
    """
    /// \(generatedSelectionSetName(
    from: selectionSet.scopePath.head,
    withFieldPath: selectionSet.entity.fieldPath.toArray(),
    removingFirst: true))
    """
  }

  // MARK: - Body
  func BodyTemplate(_ selectionSet: IR.SelectionSet) -> TemplateString {
    let selections = selectionSet.selections
    return """
    \(Self.DataFieldAndInitializerTemplate)

    \(ParentTypeTemplate(selectionSet.parentType))
    \(ifLet: selections.direct?.groupedByInclusionCondition, SelectionsTemplate )

    \(section: FieldAccessorsTemplate(selections))

    \(section: TypeCaseAccessorsTemplate(selections))

    \(section: FragmentAccessorsTemplate(selections))

    \(section: ChildEntityFieldSelectionSets(selections))

    \(section: ChildTypeCaseSelectionSets(selections))
    """
  }

  private static let DataFieldAndInitializerTemplate = """
    public let data: DataDict
    public init(data: DataDict) { self.data = data }
    """

  private func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    "public static var __parentType: ParentType { .\(type.parentTypeEnumType)(\(schema.name).\(type.name).self) }"
  }

  // MARK: - Selections
  private func SelectionsTemplate(
    _ groupedSelections: IR.DirectSelections.GroupedByInclusionCondition
  ) -> TemplateString {
    """
    public static var selections: [Selection] { [
      \(renderedSelections(groupedSelections.unconditionalSelections), terminator: ",")
      \(groupedSelections.inclusionConditionGroups.map(renderedConditionalSelectionGroup), terminator: ",")
    ] }
    """
  }

  private func renderedSelections(
    _ selections: IR.DirectSelections.ReadOnly
  ) -> [TemplateString] {
    selections.fields.values.map { FieldSelectionTemplate($0) } +
    selections.inlineFragments.values.map { TypeCaseSelectionTemplate($0.typeInfo) } +
    selections.fragments.values.map { FragmentSelectionTemplate($0) }
  }

  private func renderedConditionalSelectionGroup(
    _ conditions: AnyOf<IR.InclusionConditions>,
    _ selections: IR.DirectSelections.ReadOnly
  ) -> TemplateString {
    let renderedSelections = self.renderedSelections(selections)
    let isSelectionGroup = renderedSelections.count > 1
    return """
    .include(if: \(conditions.conditionVariableExpression), \(if: isSelectionGroup, "[")\(list: renderedSelections)\(if: isSelectionGroup, "]"))
    """
  }

  private func FieldSelectionTemplate(_ field: IR.Field) -> TemplateString {
    """
    .field("\(field.name)"\
    \(ifLet: field.alias, {", alias: \"\($0)\""})\
    , \(typeName(for: field)).self\
    \(ifLet: field.arguments,
      where: { !$0.isEmpty }, { args in
        ", arguments: " + renderValue(for: args)
    })\
    )
    """
  }

  private func typeName(for field: IR.Field, forceOptional: Bool = false) -> String {
    let fieldName: String
    switch field {
    case let scalarField as IR.ScalarField:
      fieldName = scalarField.type.rendered

    case let entityField as IR.EntityField:
      fieldName = self.nameCache.selectionSetType(for: entityField)

    default:
      fatalError()
    }

    if case .nonNull = field.type, forceOptional {
      return "\(fieldName)?"
    } else {
      return fieldName
    }

  }

  private func renderValue(for arguments: [CompilationResult.Argument]) -> TemplateString {
    "[\(list: arguments.map{ "\"\($0.name)\": " + $0.value.renderInputValueLiteral() })]"
  }

  private func TypeCaseSelectionTemplate(_ typeCase: IR.SelectionSet.TypeInfo) -> TemplateString {
    """
    .typeCase(As\(typeCase.parentType.name.firstUppercased).self)
    """
  }

  private func FragmentSelectionTemplate(_ fragment: IR.FragmentSpread) -> TemplateString {
    """
    .fragment(\(fragment.definition.name.firstUppercased).self)
    """
  }

  // MARK: - Accessors
  private func FieldAccessorsTemplate(_ selections: IR.SelectionSet.Selections) -> TemplateString {
    """
    \(ifLet: selections.direct?.fields.values, {
        "\($0.map { FieldAccessorTemplate($0) }, separator: "\n")"
      })
    \(selections.merged.fields.values.map { FieldAccessorTemplate($0) }, separator: "\n")
    """
  }

  private func FieldAccessorTemplate(_ field: IR.Field) -> TemplateString {
    """
    public var \(field.responseKey.firstLowercased): \(typeName(for: field, forceOptional: field.inclusionConditions != nil)) { data["\(field.responseKey)"] }
    """
  }

  private func TypeCaseAccessorsTemplate(
    _ selections: IR.SelectionSet.Selections
  ) -> TemplateString {
    """
    \(ifLet: selections.direct?.inlineFragments.values, {
        "\($0.map { TypeCaseAccessorTemplate($0) }, separator: "\n")"
      })
    \(selections.merged.inlineFragments.values.map { TypeCaseAccessorTemplate($0) }, separator: "\n")
    """
  }

  private func TypeCaseAccessorTemplate(_ typeCase: IR.SelectionSet) -> TemplateString {
    let typeName = typeCase.renderedTypeName
    return """
    public var as\(typeName): As\(typeName)? { _asType() }
    """
  }

  private func FragmentAccessorsTemplate(
    _ selections: IR.SelectionSet.Selections
  ) -> TemplateString {
    guard !(selections.direct?.fragments.isEmpty ?? true) ||
            !selections.merged.fragments.isEmpty else {
      return ""
    }

    return """
    public struct Fragments: FragmentContainer {
      \(Self.DataFieldAndInitializerTemplate)

      \(ifLet: selections.direct?.fragments.values, {
          "\($0.map { FragmentAccessorTemplate($0) }, separator: "\n")"
        })
      \(selections.merged.fragments.values.map { FragmentAccessorTemplate($0) }, separator: "\n")
    }
    """
  }

  private func FragmentAccessorTemplate(_ fragment: IR.FragmentSpread) -> TemplateString {
    let name = fragment.definition.name
    return """
    public var \(name.firstLowercased): \(name.firstUppercased) { _toFragment() }
    """
  }

  // MARK: - Nested Selection Sets
  private func ChildEntityFieldSelectionSets(
    _ selections: IR.SelectionSet.Selections
  ) -> TemplateString {
    """
    \(ifLet: selections.direct?.fields.values.compactMap { $0 as? IR.EntityField }, {
      "\($0.map { render(field: $0) }, separator: "\n\n")"
    })
    \(selections.merged.fields.values.compactMap { field -> String? in
      guard let field = field as? IR.EntityField,
        field.selectionSet.shouldBeRendered else { return nil }
      return render(field: field)
    }, separator: "\n\n")
    """
  }

  private func ChildTypeCaseSelectionSets(_ selections: IR.SelectionSet.Selections) -> TemplateString {
    """
    \(ifLet: selections.direct?.inlineFragments.values, {
        "\($0.map { render(typeCase: $0) }, separator: "\n\n")"
      })
    \(selections.merged.inlineFragments.values.map { render(typeCase: $0) }, separator: "\n\n")
    """    
  }

}

fileprivate class SelectionSetNameCache {
  private var generatedSelectionSetNames: [ObjectIdentifier: String] = [:]

  // MARK: Entity Field
  func selectionSetName(for field: IR.EntityField) -> String {
    let objectId = ObjectIdentifier(field)
    if let name = generatedSelectionSetNames[objectId] { return name }

    let name = computeGeneratedSelectionSetName(for: field)
    generatedSelectionSetNames[objectId] = name
    return name
  }

  func selectionSetType(for field: IR.EntityField) -> String {
    field.type.rendered(replacingNamedTypeWith: selectionSetName(for: field))
  }

  // MARK: Name Computation
  func computeGeneratedSelectionSetName(for field: IR.EntityField) -> String {
    let selectionSet = field.selectionSet
    if selectionSet.shouldBeRendered {
      return field.formattedFieldName

    } else {
      return selectionSet.selections.merged.mergedSources
        .first.unsafelyUnwrapped
        .generatedSelectionSetName(for: selectionSet)
    }
  }
}

// MARK: - Helper Extensions

fileprivate extension GraphQLCompositeType {
  var parentTypeEnumType: String {
    switch self {
    case is GraphQLObjectType: return "Object"
    case is GraphQLInterfaceType: return "Interface"
    case is GraphQLUnionType: return "Union"
    default: fatalError("Invalid parentType for Selection Set: \(self)")
    }
  }
}

fileprivate extension IR.SelectionSet {

  /// Indicates if the SelectionSet should be rendered by the template engine.
  ///
  /// If `false`, references to the selection set can point to another rendered selection set.
  /// Use `nameCache.selectionSetName(for:)` to get the name of the rendered selection set that
  /// should be referenced.
  var shouldBeRendered: Bool {
    return selections.direct != nil || selections.merged.mergedSources.count != 1
  }

  var renderedTypeName: String {
    self.parentType.name.firstUppercased
  }

}

fileprivate extension IR.EntityField {

  var formattedFieldName: String {
    return StringInflector.default.singularize(responseKey.firstUppercased)
  }

}

fileprivate extension IR.MergedSelections.MergedSource {

  func generatedSelectionSetName(for selectionSet: IR.SelectionSet) -> String {
    if let fragment = fragment {
      return generatedSelectionSetNameForMergedEntity(in: fragment)
    }

    var targetTypePathCurrentNode = selectionSet.typeInfo.scopePath.last
    var sourceTypePathCurrentNode = typeInfo.scopePath.last
    var nodesToSharedRoot = 0

    while targetTypePathCurrentNode.value == sourceTypePathCurrentNode.value {
      guard let previousFieldNode = targetTypePathCurrentNode.previous,
            let previousSourceNode = sourceTypePathCurrentNode.previous else {
              break
            }

      targetTypePathCurrentNode = previousFieldNode
      sourceTypePathCurrentNode = previousSourceNode
      nodesToSharedRoot += 1
    }

    let fieldPath = Array(typeInfo.entity.fieldPath
                            .toArray()
                            .suffix(nodesToSharedRoot + 1))

    let selectionSetName = ApolloCodegenLib.generatedSelectionSetName(
      from: sourceTypePathCurrentNode,
      withFieldPath: fieldPath,
      removingFirst: nodesToSharedRoot <= 1
    )

    return selectionSetName
  }

  private func generatedSelectionSetNameForMergedEntity(in fragment: IR.NamedFragment) -> String {
    let selectionSetName = ApolloCodegenLib.generatedSelectionSetName(
      from: typeInfo.scopePath.head.next!,
      withFieldPath: Array(typeInfo.entity.fieldPath.toArray().dropFirst())
    )

    return "\(fragment.definition.name).\(selectionSetName)"
  }

}

private func generatedSelectionSetName(
  from typePathNode: LinkedList<IR.ScopeDescriptor>.Node,
  withFieldPath fieldPath: [String],
  removingFirst: Bool = false
) -> String {
  var currentNode = Optional(typePathNode)
  var fieldPathIndex = 0

  var components: [String] = []

  repeat {
    let fieldName = fieldPath[fieldPathIndex]
    components.append(StringInflector.default.singularize(fieldName.firstUppercased))

    var currentTypeScopeNode = currentNode.unsafelyUnwrapped.value.scopePath.head
    while let typeCaseNode = currentTypeScopeNode.next {
      components.append(typeCaseNode.value.selectionSetNameComponent)
      currentTypeScopeNode = typeCaseNode
    }

    fieldPathIndex += 1
    currentNode = currentNode.unsafelyUnwrapped.next
  } while currentNode !== nil

  if removingFirst { components.removeFirst() }

  return components.joined(separator: ".")
}

fileprivate extension IR.ScopeCondition {

  var selectionSetNameComponent: String {
    "As\(type?.name.firstUppercased ?? "")"
  }
  
}

fileprivate extension AnyOf where T == IR.InclusionConditions {
  var conditionVariableExpression: TemplateString {
    """
    \(elements.map {
      $0.conditionVariableExpression(wrapInParenthesisIfMultiple: elements.count > 1)
    }, separator: " || ")
    """
  }
}

fileprivate extension IR.InclusionConditions {
  func conditionVariableExpression(wrapInParenthesisIfMultiple: Bool) -> TemplateString {
    let shouldWrap = wrapInParenthesisIfMultiple && count > 1
    return """
    \(if: shouldWrap, "(")\(map(\.conditionVariableExpression), separator: " && ")\(if: shouldWrap, ")")
    """
  }
}

fileprivate extension IR.InclusionCondition {
  var conditionVariableExpression: TemplateString {
    """
    \(if: isInverted, "!")"\(variable)"
    """
  }
}
