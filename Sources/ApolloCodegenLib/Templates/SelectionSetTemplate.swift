import InflectorKit
import OrderedCollections

struct SelectionSetTemplate {

  let definition: IR.Definition
  let isMutable: Bool
  let generateInitializers: Bool
  let config: ApolloCodegen.ConfigurationContext
  let renderAccessControl: () -> String

  private let nameCache: SelectionSetNameCache

  init(
    definition: IR.Definition,
    generateInitializers: Bool,
    config: ApolloCodegen.ConfigurationContext,
    renderAccessControl: @autoclosure @escaping () -> String
  ) {
    self.definition = definition
    self.isMutable = definition.isMutable
    self.generateInitializers = generateInitializers
    self.config = config
    self.renderAccessControl = renderAccessControl

    self.nameCache = SelectionSetNameCache(config: config)
  }

  func renderBody() -> TemplateString {
    BodyTemplate(definition.rootField.selectionSet)
  }

  // MARK: - Field
  func render(field: IR.EntityField) -> String {
    TemplateString(
    """
    \(SelectionSetNameDocumentation(field.selectionSet))
    \(renderAccessControl())\
    struct \(field.formattedSelectionSetName(with: config.pluralizer)): \(SelectionSetType()) {
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
    \(renderAccessControl())\
    struct \(inlineFragment.renderedTypeName): \(SelectionSetType(asInlineFragment: true))\
    \(if: inlineFragment.isCompositeSelectionSet, ", \(config.ApolloAPITargetName).CompositeInlineFragment") \
    {
      \(BodyTemplate(inlineFragment))
    }
    """
    ).description
  }

  // MARK: - Selection Set Type
  private func SelectionSetType(asInlineFragment: Bool = false) -> TemplateString {
    let selectionSetTypeName: String
    switch (isMutable, asInlineFragment) {
    case (false, false):
      selectionSetTypeName = "SelectionSet"
    case (false, true):
      selectionSetTypeName = "InlineFragment"
    case (true, false):
      selectionSetTypeName = "MutableSelectionSet"
    case (true, true):
      selectionSetTypeName = "MutableInlineFragment"
    }

    return "\(config.schemaNamespace.firstUppercased).\(selectionSetTypeName)"
  }

  // MARK: - Selection Set Name Documentation
  func SelectionSetNameDocumentation(_ selectionSet: IR.SelectionSet) -> TemplateString {
    """
    /// \(SelectionSetNameGenerator.generatedSelectionSetName(
    from: selectionSet.scopePath.head,
    withFieldPath: selectionSet.entity.fieldPath.head,
    removingFirst: true,
    pluralizer: config.pluralizer))
    \(if: config.options.schemaDocumentation == .include, """
      ///
      /// Parent Type: `\(selectionSet.parentType.name.firstUppercased)`
      """)
    """
  }

  // MARK: - Body
  func BodyTemplate(_ selectionSet: IR.SelectionSet) -> TemplateString {
    let selections = selectionSet.selections
    let scope = selectionSet.typeInfo.scope
    return """
    \(DataFieldAndInitializerTemplate())

    \(RootEntityTypealias(selectionSet))
    \(ParentTypeTemplate(selectionSet.parentType))
    \(ifLet: selections.direct?.groupedByInclusionCondition, { SelectionsTemplate($0, in: scope) })
    \(if: selectionSet.isCompositeInlineFragment, MergedSourcesTemplate(selectionSet))

    \(section: FieldAccessorsTemplate(selections, in: scope))

    \(section: InlineFragmentAccessorsTemplate(selections))

    \(section: FragmentAccessorsTemplate(selections, in: scope))

    \(section: "\(if: generateInitializers, InitializerTemplate(selectionSet))")

    \(section: ChildEntityFieldSelectionSets(selections))

    \(section: ChildTypeCaseSelectionSets(selections))
    """
  }

  private func DataFieldAndInitializerTemplate() -> String {
    let accessControl = renderAccessControl()

    return """
    \(accessControl)\(isMutable ? "var" : "let") __data: DataDict
    \(accessControl)init(_dataDict: DataDict) { __data = _dataDict }
    """
  }

  private func RootEntityTypealias(_ selectionSet: IR.SelectionSet) -> TemplateString {
    guard !selectionSet.isEntityRoot else { return "" }
    let rootEntityName = fullyQualifiedGeneratedSelectionSetName(
      for: selectionSet.typeInfo,
      to: selectionSet.scopePath.last.value.scopePath.head
    )

    return """
    \(renderAccessControl())typealias RootEntityType = \(rootEntityName)
    """
  }

  private func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    """
    \(renderAccessControl())\
    static var __parentType: \(config.ApolloAPITargetName).ParentType { \
    \(GeneratedSchemaTypeReference(type)) }
    """
  }

  private func MergedSourcesTemplate(_ selectionSet: IR.SelectionSet) -> TemplateString {
    return """
    public static var __mergedSources: [any \(config.ApolloAPITargetName).SelectionSet.Type] { [
      \(selectionSet.selections.merged.mergedSources.map {
        let selectionSetName = fullyQualifiedGeneratedSelectionSetName(for: $0.typeInfo)
        return "\(selectionSetName).self"
      })
    ] }
    """
  }

  private func GeneratedSchemaTypeReference(_ type: GraphQLCompositeType) -> TemplateString {
    "\(config.schemaNamespace.firstUppercased).\(type.schemaTypesNamespace).\(type.name.firstUppercased)"
  }

  // MARK: - Selections
  typealias DeprecatedArgument = (field: String, arg: String, reason: String)

  private func SelectionsTemplate(
    _ groupedSelections: IR.DirectSelections.GroupedByInclusionCondition,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    var deprecatedArguments: [DeprecatedArgument]? =
    config.options.warningsOnDeprecatedUsage == .include ? [] : nil

    let selectionsTemplate = TemplateString("""
    \(renderAccessControl())\
    static var __selections: [\(config.ApolloAPITargetName).Selection] { [
      \(if: shouldIncludeTypenameSelection(for: scope), ".field(\"__typename\", String.self),")
      \(renderedSelections(groupedSelections.unconditionalSelections, &deprecatedArguments), terminator: ",")
      \(groupedSelections.inclusionConditionGroups.map {
        renderedConditionalSelectionGroup($0, $1, in: scope, &deprecatedArguments)
      }, terminator: ",")
    ] }
    """)
    return """
    \(if: deprecatedArguments != nil && !deprecatedArguments.unsafelyUnwrapped.isEmpty, """
      \(deprecatedArguments.unsafelyUnwrapped.map { """
        \(field: $0.field, argument: $0.arg, warningReason: $0.reason)
        """})
      """)
    \(selectionsTemplate)
    """
  }

  private func shouldIncludeTypenameSelection(for scope: IR.ScopeDescriptor) -> Bool {
    return scope.scopePath.count == 1 && !scope.type.isRootFieldType
  }

  private func renderedSelections(
    _ selections: IR.DirectSelections.ReadOnly,
    _ deprecatedArguments: inout [DeprecatedArgument]?
  ) -> [TemplateString] {
    selections.fields.values.map { FieldSelectionTemplate($0, &deprecatedArguments) } +
    selections.inlineFragments.values.map { InlineFragmentSelectionTemplate($0) } +
    selections.fragments.values.map { FragmentSelectionTemplate($0) }
  }

  private func renderedConditionalSelectionGroup(
    _ conditions: AnyOf<IR.InclusionConditions>,
    _ selections: IR.DirectSelections.ReadOnly,
    in scope: IR.ScopeDescriptor,
    _ deprecatedArguments: inout [DeprecatedArgument]?
  ) -> TemplateString {
    let renderedSelections = self.renderedSelections(selections, &deprecatedArguments)
    guard !scope.matches(conditions) else {
      return "\(renderedSelections)"
    }

    let isSelectionGroup = renderedSelections.count > 1
    return """
    .include(if: \(conditions.conditionVariableExpression), \(if: isSelectionGroup, "[")\(list: renderedSelections, terminator: isSelectionGroup ? "," : nil)\(if: isSelectionGroup, "]"))
    """
  }

  private func FieldSelectionTemplate(
    _ field: IR.Field,
    _ deprecatedArguments: inout [DeprecatedArgument]?
  ) -> TemplateString {
    """
    .field("\(field.name)"\
    \(ifLet: field.alias, {", alias: \"\($0)\""})\
    , \(typeName(for: field)).self\
    \(ifLet: field.arguments,
      where: { !$0.isEmpty }, { args in
        ", arguments: " + renderValue(for: args, onFieldNamed: field.name, &deprecatedArguments)
    })\
    )
    """
  }

  private func typeName(for field: IR.Field, forceOptional: Bool = false) -> String {
    let fieldName: String
    switch field {
    case let scalarField as IR.ScalarField:
      fieldName = scalarField.type.rendered(as: .selectionSetField(), config: config.config)

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

  private func renderValue(
    for arguments: [CompilationResult.Argument],
    onFieldNamed fieldName: String,
    _ deprecatedArguments: inout [DeprecatedArgument]?
  ) -> TemplateString {
    """
    [\(list: arguments.map { arg -> TemplateString in
      if let deprecationReason = arg.deprecationReason {
        deprecatedArguments?.append((field: fieldName, arg: arg.name, reason: deprecationReason))
      }
      return "\"\(arg.name)\": " + arg.value.renderInputValueLiteral()
    })]
    """
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
    return """
    \(documentation: field.underlyingField.documentation, config: config)
    \(deprecationReason: field.underlyingField.deprecationReason, config: config)
    \(renderAccessControl())var \(field.responseKey.asFieldPropertyName): \
    \(typeName(for: field, forceOptional: field.isConditionallyIncluded(in: scope))) {\
    \(if: isMutable,
      """

        get { __data["\(field.responseKey)"] }
        set { __data["\(field.responseKey)"] = newValue }
      }
      """, else:
      """
       __data["\(field.responseKey)"] }
      """)
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
    \(renderAccessControl())var \(typeName.firstLowercased): \(typeName)? {\
    \(if: isMutable,
      """

        get { _asInlineFragment() }
        set { if let newData = newValue?.__data._data { __data._data = newData }}
      }
      """,
      else: " _asInlineFragment() }"
    )
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
    \(renderAccessControl())struct Fragments: FragmentContainer {
      \(DataFieldAndInitializerTemplate())

      \(ifLet: selections.direct?.fragments.values, {
        "\($0.map { FragmentAccessorTemplate($0, in: scope) }, separator: "\n")"
        })
      \(selections.merged.fragments.values.map {
          FragmentAccessorTemplate($0, in: scope)
        }, separator: "\n")
    }
    """
  }

  private func FragmentAccessorTemplate(
    _ fragment: IR.FragmentSpread,
    in scope: IR.ScopeDescriptor
  ) -> TemplateString {
    let name = fragment.definition.name
    let propertyName = name.firstLowercased
    let typeName = name.firstUppercased
    let isOptional = fragment.inclusionConditions != nil &&
    !scope.matches(fragment.inclusionConditions.unsafelyUnwrapped)

    return """
    \(renderAccessControl())var \(propertyName): \(typeName)\
    \(if: isOptional, "?") {\
    \(if: isMutable,
      """

        get { _toFragment() }
        _modify { var f = \(propertyName); yield &f; \(
          if: isOptional,
            "if let newData = f?.__data { __data = newData }",
          else: "__data = f.__data"
        ) }
        @available(*, unavailable, message: "mutate properties of the fragment instead.")
        set { preconditionFailure() }
      }
      """,
      else: " _toFragment() }"
    )
    """
  }

  // MARK: - SelectionSet Initializer

  private func InitializerTemplate(_ selectionSet: IR.SelectionSet) -> TemplateString {
    return """
    \(renderAccessControl())init(
      \(InitializerSelectionParametersTemplate(selectionSet))
    ) {
      self.init(_dataDict: DataDict(
        data: [
          \(InitializerDataDictTemplate(selectionSet))
        ],
        fulfilledFragments: \(InitializerFulfilledFragments(selectionSet))
      ))
    }
    """
  }

  private func InitializerSelectionParametersTemplate(
    _ selectionSet: IR.SelectionSet
  ) -> TemplateString {
    let isConcreteType = selectionSet.parentType is GraphQLObjectType
    let allFields = selectionSet.selections.makeFieldIterator()

    return TemplateString("""
    \(if: !isConcreteType, "__typename: String\(if: !allFields.isEmpty, ",")")
    \(IteratorSequence(allFields).map({
      InitializerParameterTemplate($0, scope: selectionSet.scope)
    }))
    """
    )
  }

  private func InitializerParameterTemplate(
    _ field: IR.Field,
    scope: IR.ScopeDescriptor
  ) -> TemplateString {
    let isOptional: Bool = field.type.isNullable || field.isConditionallyIncluded(in: scope)
    return """
    \(field.responseKey.asFieldPropertyName): \(typeName(for: field, forceOptional: isOptional))\
    \(if: isOptional, " = nil")
    """
  }

  private func InitializerDataDictTemplate(
    _ selectionSet: IR.SelectionSet
  ) -> TemplateString {
    let isConcreteType = selectionSet.parentType is GraphQLObjectType
    let allFields = selectionSet.selections.makeFieldIterator()

    return TemplateString("""
    "__typename": \
    \(if: isConcreteType,
      "\(GeneratedSchemaTypeReference(selectionSet.parentType)).typename,",
      else: "__typename,")
    \(IteratorSequence(allFields).map(InitializerDataDictFieldTemplate(_:)), terminator: ",")
    """
    )
  }

  private func InitializerDataDictFieldTemplate(
    _ field: IR.Field
  ) -> TemplateString {
    let isEntityField: Bool = {
      switch field.type.innerType {
      case .entity: return true
      default: return false
      }
    }()

    return """
    "\(field.responseKey)": \(field.responseKey.asFieldPropertyName)\
    \(if: isEntityField, "._fieldData")
    """
  }

  private func InitializerFulfilledFragments(
    _ selectionSet: IR.SelectionSet
  ) -> TemplateString {
    var fulfilledFragments: [String] = ["Self"]

    var next = selectionSet.scopePath.last.value.scopePath.head
    while next.next != nil {
      defer { next = next.next.unsafelyUnwrapped }

      let selectionSetName = SelectionSetNameGenerator.generatedSelectionSetName(
        from: selectionSet.scopePath.head,
        to: next,
        withFieldPath: selectionSet.entity.fieldPath.head,
        removingFirst: selectionSet.scopePath.head.value.type.isRootFieldType,
        pluralizer: config.pluralizer
      )

      fulfilledFragments.append(selectionSetName)
    }

    let allFragments = IteratorSequence(selectionSet.selections.makeFragmentIterator())
    for fragment in allFragments {
      if let conditions = fragment.inclusionConditions,
         !selectionSet.typeInfo.scope.matches(conditions) {
        continue
      }
      fulfilledFragments.append(fragment.definition.name.firstUppercased)
    }

    return """
    [
      \(fulfilledFragments.map { "ObjectIdentifier(\($0).self)" })
    ]
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

  // MARK: - SelectionSet Name Computation

  private func fullyQualifiedGeneratedSelectionSetName(
    for typeInfo: IR.SelectionSet.TypeInfo,
    to toNode: LinkedList<IR.ScopeCondition>.Node? = nil
  ) -> String {
    let rootNode = typeInfo.scopePath.head
    let rootTypeIsOperationRoot = rootNode.value.type.isRootFieldType

    let rootEntityName = SelectionSetNameGenerator.generatedSelectionSetName(
      from: rootNode,
      to: toNode,
      withFieldPath: typeInfo.entity.fieldPath.head,
      removingFirst: rootTypeIsOperationRoot,
      pluralizer: config.pluralizer
    )

    return rootTypeIsOperationRoot ?
    "\(definition.generatedDefinitionName.firstUppercased).Data.\(rootEntityName)" : rootEntityName
  }

}

fileprivate class SelectionSetNameCache {
  private var generatedSelectionSetNames: [ObjectIdentifier: String] = [:]

  let config: ApolloCodegen.ConfigurationContext

  init(config: ApolloCodegen.ConfigurationContext) {
    self.config = config
  }

  func selectionSetName(for selectionSet: IR.SelectionSet) -> String {
    let objectId = ObjectIdentifier(selectionSet)
    if let name = generatedSelectionSetNames[objectId] { return name }

    let name = computeGeneratedSelectionSetName(for: selectionSet)
    generatedSelectionSetNames[objectId] = name
    return name
  }

  // MARK: Entity Field
  func selectionSetName(for field: IR.EntityField) -> String {
    return selectionSetName(for: field.selectionSet)
  }

  func selectionSetType(for field: IR.EntityField) -> String {
    field.type.rendered(
      as: .selectionSetField(),
      replacingNamedTypeWith: selectionSetName(for: field),
      config: config.config
    )
  }

  // MARK: Name Computation
  func computeGeneratedSelectionSetName(for selectionSet: IR.SelectionSet) -> String {
    if selectionSet.shouldBeRendered {
      return selectionSet.entity.fieldPath.last.value.formattedSelectionSetName(
        with: config.pluralizer
      )

    } else {
      return selectionSet.selections.merged.mergedSources
        .first.unsafelyUnwrapped
        .generatedSelectionSetName(
          for: selectionSet.typeInfo,
          pluralizer: config.pluralizer
        )
    }
  }
}

// MARK: - Helper Extensions

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

  var isCompositeSelectionSet: Bool {
    return selections.direct?.isEmpty ?? true
  }

  var isCompositeInlineFragment: Bool {
    return !self.isEntityRoot && isCompositeSelectionSet
  }

}

fileprivate extension IR.MergedSelections.MergedSource {

  func generatedSelectionSetName(
    for targetTypeInfo: IR.SelectionSet.TypeInfo,
    pluralizer: Pluralizer
  ) -> String {
    if let fragment = fragment {
      return generatedSelectionSetNameForMergedEntity(
        in: fragment,
        pluralizer: pluralizer
      )
    }

    var targetTypePathCurrentNode = targetTypeInfo.scopePath.last
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

    let fieldPath = typeInfo.entity.fieldPath.node(
      at: typeInfo.entity.fieldPath.count - (nodesToSharedRoot + 1)
    )

    let selectionSetName = SelectionSetNameGenerator.generatedSelectionSetName(
      from: sourceTypePathCurrentNode,
      withFieldPath: fieldPath,
      removingFirst: nodesToSharedRoot <= 1,
      pluralizer: pluralizer
    )

    return selectionSetName
  }

  private func generatedSelectionSetNameForMergedEntity(
    in fragment: IR.NamedFragment,
    pluralizer: Pluralizer
  ) -> String {
    var selectionSetNameComponents: [String] = [fragment.definition.name.firstUppercased]

    let rootEntityScopePath = typeInfo.scopePath.head
    if let rootEntityTypeConditionPath = rootEntityScopePath.value.scopePath.head.next {
      selectionSetNameComponents.append(
        SelectionSetNameGenerator.ConditionPath.path(for: rootEntityTypeConditionPath)
      )
    }

    if let fragmentNestedTypePath = rootEntityScopePath.next {
      selectionSetNameComponents.append(
        SelectionSetNameGenerator.generatedSelectionSetName(
          from: fragmentNestedTypePath,
          withFieldPath: typeInfo.entity.fieldPath.head.next.unsafelyUnwrapped,
          pluralizer: pluralizer
        )
      )
    }

    return selectionSetNameComponents.joined(separator: ".")
  }

}

fileprivate struct SelectionSetNameGenerator {

  static func generatedSelectionSetName(
    from typePathNode: LinkedList<IR.ScopeDescriptor>.Node,
    to endingNode: LinkedList<IR.ScopeCondition>.Node? = nil,
    withFieldPath fieldPathNode: IR.Entity.FieldPath.Node,
    removingFirst: Bool = false,
    pluralizer: Pluralizer
  ) -> String {
    var currentTypePathNode = Optional(typePathNode)
    var currentFieldPathNode = Optional(fieldPathNode)

    var components: [String] = []

    iterateEntityScopes: repeat {
      let fieldName = currentFieldPathNode.unsafelyUnwrapped.value
        .formattedSelectionSetName(with: pluralizer)
      components.append(fieldName)

      var currentConditionNode = Optional(currentTypePathNode.unsafelyUnwrapped.value.scopePath.head)
      guard currentConditionNode !== endingNode else {
        break iterateEntityScopes
      }

      currentConditionNode = currentTypePathNode.unsafelyUnwrapped.value.scopePath.head.next
      iterateConditionScopes: while currentConditionNode !== nil {
        let node = currentConditionNode.unsafelyUnwrapped

        components.append(node.value.selectionSetNameComponent)
        guard node !== endingNode else {
          break iterateEntityScopes
        }

        currentConditionNode = node.next
      }

      currentTypePathNode = currentTypePathNode.unsafelyUnwrapped.next
      currentFieldPathNode = currentFieldPathNode.unsafelyUnwrapped.next
    } while currentTypePathNode !== nil

    if removingFirst { components.removeFirst() }

    return components.joined(separator: ".")
  }

  fileprivate struct ConditionPath {
    static func path(for conditions: LinkedList<IR.ScopeCondition>.Node) -> String {
      conditions.map(\.selectionSetNameComponent).joined(separator: ".")
    }
  }
}

fileprivate extension IR.ScopeCondition {

  var selectionSetNameComponent: String {
    return TemplateString("""
    \(ifLet: type, { "As\($0.name.firstUppercased)" })\
    \(ifLet: conditions, { "If\($0.typeNameComponents)"})
    """).description
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

  func isConditionallyIncluded(in scope: IR.ScopeDescriptor) -> Bool {
    guard let conditions = self.inclusionConditions else { return false }
    return !scope.matches(conditions)
  }
}

extension IR.SelectionSet.Selections {
  fileprivate func makeFieldIterator() -> SelectionsIterator<IR.Field> {
    SelectionsIterator(direct: direct?.fields, merged: merged.fields)
  }

  fileprivate func makeFragmentIterator() -> SelectionsIterator<IR.FragmentSpread> {
    SelectionsIterator(direct: direct?.fragments, merged: merged.fragments)
  }

  fileprivate struct SelectionsIterator<SelectionType>: IteratorProtocol {
    typealias SelectionDictionary = OrderedDictionary<String, SelectionType>

    private let direct: SelectionDictionary?
    private let merged: SelectionDictionary
    private var directIterator: IndexingIterator<SelectionDictionary.Values>?
    private var mergedIterator: IndexingIterator<SelectionDictionary.Values>

    fileprivate init(
      direct: SelectionDictionary?,
      merged: SelectionDictionary
    ) {
      self.direct = direct
      self.merged = merged
      self.directIterator = self.direct?.values.makeIterator()
      self.mergedIterator = self.merged.values.makeIterator()
    }

    mutating func next() -> SelectionType? {
      directIterator?.next() ?? mergedIterator.next()
    }

    var isEmpty: Bool {
      return (direct?.isEmpty ?? true) && merged.isEmpty
    }

  }
}
