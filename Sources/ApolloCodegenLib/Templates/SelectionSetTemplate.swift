import ApolloUtils
import InflectorKit

struct SelectionSetTemplate {

  let schema: IR.Schema
  private let nameCache: SelectionSetNameCache

  init(schema: IR.Schema) {
    self.schema = schema
    self.nameCache = SelectionSetNameCache(schema: schema)
  }

  // MARK: - Operation
  func render(for operation: IR.Operation) -> String {
    TemplateString(
    """
    public struct Data: \(schema.name.firstUppercased).SelectionSet {
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
    public struct \(field.formattedFieldName): \(schema.name.firstUppercased).SelectionSet {
      \(BodyTemplate(field.selectionSet))
    }
    """
    ).description
  }

  // MARK: - Inline Fragment
  func render(inlineFragment: IR.SelectionSet) -> String {
    TemplateString(
    """
    \(SelectionSetNameDocumentation(inlineFragment))
    public struct \(inlineFragment.renderedTypeName): \(schema.name.firstUppercased).InlineFragment {
      \(BodyTemplate(inlineFragment))
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
    let scope = selectionSet.typeInfo.scope
    return """
    \(Self.DataFieldAndInitializerTemplate)

    \(ParentTypeTemplate(selectionSet.parentType))
    \(ifLet: selections.direct?.groupedByInclusionCondition, { SelectionsTemplate($0, in: scope) })

    \(section: FieldAccessorsTemplate(selections, in: scope))

    \(section: InlineFragmentAccessorsTemplate(selections))

    \(section: FragmentAccessorsTemplate(selections, in: scope))

    \(section: ChildEntityFieldSelectionSets(selections))

    \(section: ChildTypeCaseSelectionSets(selections))
    """
  }

  private static let DataFieldAndInitializerTemplate = """
    public let data: DataDict
    public init(data: DataDict) { self.data = data }
    """

  private func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    "public static var __parentType: ParentType { .\(type.parentTypeEnumType)(\(schema.name.firstUppercased).\(type.name.firstUppercased).self) }"
  }

  // MARK: - Selections
  private func SelectionsTemplate(
    _ groupedSelections: IR.DirectSelections.GroupedByInclusionCondition,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    """
    public static var selections: [Selection] { [
      \(renderedSelections(groupedSelections.unconditionalSelections), terminator: ",")
      \(groupedSelections.inclusionConditionGroups.map {
        renderedConditionalSelectionGroup($0, $1, in: scope)
      }, terminator: ",")
    ] }
    """
  }

  private func renderedSelections(
    _ selections: IR.DirectSelections.ReadOnly
  ) -> [TemplateString] {
    selections.fields.values.map { FieldSelectionTemplate($0) } +
    selections.inlineFragments.values.map { InlineFragmentSelectionTemplate($0) } +
    selections.fragments.values.map { FragmentSelectionTemplate($0) }
  }

  private func renderedConditionalSelectionGroup(
    _ conditions: AnyOf<IR.InclusionConditions>,
    _ selections: IR.DirectSelections.ReadOnly,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    let renderedSelections = self.renderedSelections(selections)
    guard !scope.matches(conditions) else {
      return "\(renderedSelections)"
    }

    let isSelectionGroup = renderedSelections.count > 1
    return """
    .include(if: \(conditions.conditionVariableExpression), \(if: isSelectionGroup, "[")\(list: renderedSelections, terminator: isSelectionGroup ? "," : nil)\(if: isSelectionGroup, "]"))
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
      fieldName = scalarField.type.rendered(inSchemaNamed: schema.name)

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

  private func InlineFragmentSelectionTemplate(_ inlineFragment: IR.SelectionSet) -> TemplateString {
    """
    .inlineFragment(\(inlineFragment.renderedTypeName).self)
    """
  }

  private func FragmentSelectionTemplate(_ fragment: IR.FragmentSpread) -> TemplateString {
    """
    .fragment(\(fragment.definition.name.firstUppercased).self)
    """
  }

  // MARK: - Accessors
  private func FieldAccessorsTemplate(
    _ selections: IR.SelectionSet.Selections,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    """
    \(ifLet: selections.direct?.fields.values, {
      "\($0.map { FieldAccessorTemplate($0, in: scope) }, separator: "\n")"
      })
    \(selections.merged.fields.values.map { FieldAccessorTemplate($0, in: scope) }, separator: "\n")
    """
  }

  private func FieldAccessorTemplate(
    _ field: IR.Field,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    let isConditionallyIncluded: Bool = {
      guard let conditions = field.inclusionConditions else { return false }
      return !scope.matches(conditions)
    }()
    return """
    public var \(field.responseKey.firstLowercased): \
    \(typeName(for: field, forceOptional: isConditionallyIncluded)) \
    { data["\(field.responseKey)"] }
    """
  }

  private func InlineFragmentAccessorsTemplate(
    _ selections: IR.SelectionSet.Selections
  ) -> TemplateString {
    """
    \(ifLet: selections.direct?.inlineFragments.values, {
        "\($0.map { InlineFragmentAccessorTemplate($0) }, separator: "\n")"
      })
    \(selections.merged.inlineFragments.values.map { InlineFragmentAccessorTemplate($0) }, separator: "\n")
    """
  }

  private func InlineFragmentAccessorTemplate(_ inlineFragment: IR.SelectionSet) -> TemplateString {
    let typeName = inlineFragment.renderedTypeName
    return """
    public var \(typeName.firstLowercased): \(typeName)? { _asInlineFragment\
    (\(ifLet: inlineFragment.inclusionConditions, {
    "if: \($0.conditionVariableExpression())"
    })) }
    """
  }

  private func FragmentAccessorsTemplate(
    _ selections: IR.SelectionSet.Selections,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    guard !(selections.direct?.fragments.isEmpty ?? true) ||
            !selections.merged.fragments.isEmpty else {
      return ""
    }

    return """
    public struct Fragments: FragmentContainer {
      \(Self.DataFieldAndInitializerTemplate)

      \(ifLet: selections.direct?.fragments.values, {
        "\($0.map { FragmentAccessorTemplate($0, in: scope) }, separator: "\n")"
        })
      \(selections.merged.fragments.values.map { FragmentAccessorTemplate($0, in: scope) }, separator: "\n")
    }
    """
  }

  private func FragmentAccessorTemplate(
    _ fragment: IR.FragmentSpread,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    let name = fragment.definition.name
    return """
    public var \(name.firstLowercased): \(name.firstUppercased)\
    \(ifLet: fragment.inclusionConditions, where: { !scope.matches($0) }, { _ in "?" }) \
    { _toFragment() }
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
        "\($0.map { render(inlineFragment: $0) }, separator: "\n\n")"
      })
    \(selections.merged.inlineFragments.values.map { render(inlineFragment: $0) }, separator: "\n\n")
    """    
  }

}

fileprivate class SelectionSetNameCache {
  private var generatedSelectionSetNames: [ObjectIdentifier: String] = [:]

  unowned let schema: IR.Schema

  init(schema: IR.Schema) {
    self.schema = schema
  }

  // MARK: Entity Field
  func selectionSetName(for field: IR.EntityField) -> String {
    let objectId = ObjectIdentifier(field)
    if let name = generatedSelectionSetNames[objectId] { return name }

    let name = computeGeneratedSelectionSetName(for: field)
    generatedSelectionSetNames[objectId] = name
    return name
  }

  func selectionSetType(for field: IR.EntityField) -> String {
    field.type.rendered(replacingNamedTypeWith: selectionSetName(for: field), inSchemaNamed: schema.name)
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
    self.scope.scopePath.last.value.selectionSetNameComponent
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
    if let type = type {
      return "As\(type.name.firstUppercased)"
    }

    if let conditions = conditions {
      return "If\(conditions.typeNameComponents)"
    }

    fatalError("ScopeCondition is empty!")
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
  func conditionVariableExpression(wrapInParenthesisIfMultiple: Bool = false) -> TemplateString {
    let shouldWrap = wrapInParenthesisIfMultiple && count > 1
    return """
    \(if: shouldWrap, "(")\(map(\.conditionVariableExpression), separator: " && ")\(if: shouldWrap, ")")
    """
  }

  var typeNameComponents: TemplateString {
    """
    \(map(\.typeNameComponent), separator: "And")
    """
  }
}

fileprivate extension IR.InclusionCondition {
  var conditionVariableExpression: TemplateString {
    """
    \(if: isInverted, "!")"\(variable)"
    """
  }

  var typeNameComponent: TemplateString {
    """
    \(if: isInverted, "Not")\(variable.firstUppercased)
    """
  }
}

fileprivate extension IR.Field {
  var isCustomScalar: Bool {
    guard let scalar = self.type.namedType as? GraphQLScalarType else { return false }

    return scalar.isCustomScalar
  }
}

