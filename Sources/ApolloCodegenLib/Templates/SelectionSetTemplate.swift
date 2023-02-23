import InflectorKit
import OrderedCollections

struct SelectionSetTemplate {

  let isMutable: Bool
  let generateInitializers: Bool
  let config: ApolloCodegen.ConfigurationContext

  private let nameCache: SelectionSetNameCache

  init(
    mutable: Bool = false,
    generateInitializers: Bool,
    config: ApolloCodegen.ConfigurationContext
  ) {
    self.isMutable = mutable
    self.generateInitializers = generateInitializers
    self.config = config

    self.nameCache = SelectionSetNameCache(config: config)
  }

  // MARK: - Operation
  func render(for operation: IR.Operation) -> String {
    TemplateString(
    """
    public struct Data: \(SelectionSetType()) {
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
    public struct \(field.formattedSelectionSetName(with: config.pluralizer)): \(SelectionSetType()) {
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
    public struct \(inlineFragment.renderedTypeName): \(SelectionSetType(asInlineFragment: true)) {
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

    return "\(config.schemaName.firstUppercased).\(selectionSetTypeName)"
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

    \(ParentTypeTemplate(selectionSet.parentType))
    \(ifLet: selections.direct?.groupedByInclusionCondition, { SelectionsTemplate($0, in: scope) })

    \(section: FieldAccessorsTemplate(selections, in: scope))

    \(section: InlineFragmentAccessorsTemplate(selections))

    \(section: FragmentAccessorsTemplate(selections, in: scope))

    \(section: "\(if: generateInitializers, InitializerTemplate(selectionSet))")

    \(section: ChildEntityFieldSelectionSets(selections))

    \(section: ChildTypeCaseSelectionSets(selections))
    """
  }

  private func DataFieldAndInitializerTemplate() -> String {
    """
    public \(isMutable ? "var" : "let") __data: DataDict
    public init(data: DataDict) { __data = data }
    """
  }

  private func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    """
    public static var __parentType: \(config.ApolloAPITargetName).ParentType { \
    \(GeneratedTypeReference(type)) }
    """
  }

  private func GeneratedTypeReference(_ type: GraphQLCompositeType) -> TemplateString {
    "\(config.schemaName.firstUppercased).\(type.schemaTypesNamespace).\(type.name.firstUppercased)"
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
    public static var __selections: [\(config.ApolloAPITargetName).Selection] { [
      \(renderedSelections(groupedSelections.unconditionalSelections, &deprecatedArguments), terminator: ",")
      \(groupedSelections.inclusionConditionGroups.map {
        renderedConditionalSelectionGroup($0, $1, in: scope, &deprecatedArguments)
      }, terminator: ",")
    ] }
    """)
    return """
    \(if: deprecatedArguments != nil && !deprecatedArguments.unsafelyUnwrapped.isEmpty, """
      \(deprecatedArguments.unsafelyUnwrapped.map { """
        #warning("Argument '\($0.arg)' of field '\($0.field)' is deprecated. \
        Reason: '\($0.reason)'")
        """})
      """)
    \(selectionsTemplate)
    """
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
    let isConditionallyIncluded: Bool = {
      guard let conditions = field.inclusionConditions else { return false }
      return !scope.matches(conditions)
    }()
    return """
    \(documentation: field.underlyingField.documentation, config: config)
    \(deprecationReason: field.underlyingField.deprecationReason, config: config)
    public var \(field.responseKey.firstLowercased.asFieldAccessorPropertyName): \
    \(typeName(for: field, forceOptional: isConditionallyIncluded)) {\
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
    public var \(typeName.firstLowercased): \(typeName)? {\
    \(if: isMutable,
      """

        get { \(InlineFragmentGetter(inlineFragment)) }
        set { if let newData = newValue?.__data._data { __data._data = newData }}
      }
      """,
      else: " \(InlineFragmentGetter(inlineFragment)) }"
    )
    """
  }

  private func InlineFragmentGetter(_ inlineFragment: IR.SelectionSet) -> TemplateString {
    """
    _asInlineFragment\
    (\(ifLet: inlineFragment.inclusionConditions, {
      "if: \($0.conditionVariableExpression())"
    }))
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

    let getter = FragmentGetter(
      fragment,
      if: isOptional ? fragment.inclusionConditions.unsafelyUnwrapped : nil
    )

    return """
    public var \(propertyName): \(typeName)\
    \(if: isOptional, "?") {\
    \(if: isMutable,
      """

        get { \(getter) }
        _modify { var f = \(propertyName); yield &f; \(
          if: isOptional,
            "if let newData = f?.__data { __data = newData }",
          else: "__data = f.__data"
        ) }
        @available(*, unavailable, message: "mutate properties of the fragment instead.")
        set { preconditionFailure() }
      }
      """,
      else: " \(getter) }"
    )
    """
  }

  private func FragmentGetter(
    _ fragment: IR.FragmentSpread,
    if inclusionConditions: AnyOf<IR.InclusionConditions>?
  ) -> TemplateString {
    """
    _toFragment(\
    \(ifLet: inclusionConditions, {
      "if: \($0.conditionVariableExpression)"
    }))
    """
  }

  // MARK: - SelectionSet Initializer

  private func InitializerTemplate(_ selectionSet: IR.SelectionSet) -> TemplateString {
    let isConcreteType = selectionSet.parentType is GraphQLObjectType

    return """
    public init(
      \(if: !isConcreteType, "__typename: String,")
      \(InitializerSelectionParametersTemplate(selectionSet.selections))
    ) {
      \(InitializerObjectType(selectionSet))
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          \(InitializerDataDictTemplate(selectionSet.selections))
      ]))
    }
    """
  }

  private func InitializerSelectionParametersTemplate(
    _ selections: IR.SelectionSet.Selections
  ) -> TemplateString {
    let iterator = IR.SelectionSet.Selections.FieldIterator(selections: selections)

    return TemplateString("""
    \(IteratorSequence(iterator).map(InitializerParameterTemplate(_:)))
    """
    )
  }

  private func InitializerParameterTemplate(
    _ field: IR.Field
  ) -> TemplateString {
    """
    \(field.responseKey.asInputParameterName): \(typeName(for: field))\
    \(if: field.type.isNullable, " = nil")
    """
  }

  private func InitializerObjectType(_ selectionSet: IR.SelectionSet) -> TemplateString {
    let isConcreteType = selectionSet.parentType is GraphQLObjectType
    let implementedInterfaces = selectionSet.scope.matchingTypes
      .filter({ $0 is GraphQLInterfaceType })

    return """
    let objectType = \
    \(if: isConcreteType,
      GeneratedTypeReference(selectionSet.parentType),
      else: """
      \(config.ApolloAPITargetName).Object(
        typename: __typename,
        implementedInterfaces: [
          \(implementedInterfaces.map(GeneratedTypeReference(_:)))
      ])
      """
    )
    """
  }

  private func InitializerDataDictTemplate(
    _ selections: IR.SelectionSet.Selections
  ) -> TemplateString {
    let iterator = IR.SelectionSet.Selections.FieldIterator(selections: selections)

    return TemplateString("""
    "__typename": objectType.typename,
    \(IteratorSequence(iterator).map(InitializerDataDictFieldTemplate(_:)))
    """
    )
  }

  private func InitializerDataDictFieldTemplate(
    _ field: IR.Field
  ) -> TemplateString {
    """
    "\(field.responseKey)": \(field.responseKey.asInputParameterName)\
    \(if: field is IR.EntityField, "\(if: field.type.isNullable, "?").__data._data")
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

  let config: ApolloCodegen.ConfigurationContext

  init(config: ApolloCodegen.ConfigurationContext) {
    self.config = config
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
    field.type.rendered(
      as: .selectionSetField(),
      replacingNamedTypeWith: selectionSetName(for: field),
      config: config.config
    )
  }

  // MARK: Name Computation
  func computeGeneratedSelectionSetName(for field: IR.EntityField) -> String {
    let selectionSet = field.selectionSet
    if selectionSet.shouldBeRendered {
      return field.formattedSelectionSetName(
        with: config.pluralizer
      )

    } else {
      return selectionSet.selections.merged.mergedSources
        .first.unsafelyUnwrapped
        .generatedSelectionSetName(
          for: selectionSet,
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

}

fileprivate extension IR.EntityField {

  func formattedSelectionSetName(
    with pluralizer: Pluralizer
  ) -> String {
    IR.Entity.FieldPathComponent(name: responseKey, type: type)
      .formattedSelectionSetName(with: pluralizer)
  }

}

fileprivate extension IR.Entity.FieldPathComponent {

  func formattedSelectionSetName(
    with pluralizer: Pluralizer
  ) -> String {
    var fieldName = name.firstUppercased
    if type.isListType {
      fieldName = pluralizer.singularize(fieldName)
    }    
    return fieldName.asSelectionSetName
  }

}

fileprivate extension GraphQLType {

  var isListType: Bool {
    switch self {
    case .list: return true
    case let .nonNull(innerType): return innerType.isListType
    case .entity, .enum, .inputObject, .scalar: return false
    }
  }
  
}

fileprivate extension IR.MergedSelections.MergedSource {

  func generatedSelectionSetName(
    for selectionSet: IR.SelectionSet,
    pluralizer: Pluralizer
  ) -> String {
    if let fragment = fragment {
      return generatedSelectionSetNameForMergedEntity(
        in: fragment,
        pluralizer: pluralizer
      )
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
    withFieldPath fieldPathNode: IR.Entity.FieldPath.Node,
    removingFirst: Bool = false,
    pluralizer: Pluralizer
  ) -> String {
    var currentTypePathNode = Optional(typePathNode)
    var currentFieldPathNode = Optional(fieldPathNode)
    var fieldPathIndex = 0

    var components: [String] = []

    repeat {
      let fieldName = currentFieldPathNode.unsafelyUnwrapped.value
        .formattedSelectionSetName(with: pluralizer)
      components.append(fieldName)

      if let conditionNodes = currentTypePathNode.unsafelyUnwrapped.value.scopePath.head.next {
        ConditionPath.add(conditionNodes, to: &components)
      }

      fieldPathIndex += 1
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

    static func add(
      _ conditionNodes: LinkedList<IR.ScopeCondition>.Node,
      to components: inout [String]
    ) {
      for condition in conditionNodes {
        components.append(condition.selectionSetNameComponent)
      }
    }
  }
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

extension IR.SelectionSet.Selections {
  fileprivate struct FieldIterator: IteratorProtocol {
    let selections: IR.SelectionSet.Selections
    private var directIterator: IndexingIterator<OrderedDictionary<String, IR.Field>.Values>?
    private var mergedIterator: IndexingIterator<OrderedDictionary<String, IR.Field>.Values>

    init(selections: IR.SelectionSet.Selections) {
      self.selections = selections
      self.directIterator = self.selections.direct?.fields.values.makeIterator()
      self.mergedIterator = self.selections.merged.fields.values.makeIterator()
    }

    mutating func next() -> IR.Field? {
      directIterator?.next() ?? mergedIterator.next()
    }
  }
}
