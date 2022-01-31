import ApolloUtils
import InflectorKit

struct SelectionSetTemplate {

  let schema: IR.Schema
  private let nameCache = SelectionSetNameCache()

  func render(for operation: IR.Operation) -> String {
    TemplateString(
    """
    public struct Data: \(schema.name).SelectionSet {
      \(BodyTemplate(operation.rootField.selectionSet))
    }
    """
    ).description
  }

  func render(for fragment: IR.NamedFragment) -> String {
    TemplateString(
    """
    public struct \(fragment.name): \(schema.name).SelectionSet, Fragment {
      \(BodyTemplate(fragment.rootField.selectionSet))
    }
    """
    ).description
  }

  func render(field: IR.EntityField) -> String {
    TemplateString(
    """
    public struct \(field.formattedFieldName): \(schema.name).SelectionSet {
      \(BodyTemplate(field.selectionSet))
    }
    """
    ).description
  }

  func render(typeCase: IR.SelectionSet) -> String {
    TemplateString(
    """
    public struct TODO: \(schema.name).SelectionSet {
      \(BodyTemplate(typeCase))
    }
    """
    ).description
  }

  private func BodyTemplate(_ selectionSet: IR.SelectionSet) -> TemplateString {
    let selections = selectionSet.selections
    return """
    \(Self.DataFieldAndInitializerTemplate)

    \(ParentTypeTemplate(selectionSet.parentType))
    \(ifLet: selections.direct, { SelectionsTemplate($0) })

    \(ifLet: selections.direct?.fields.values, {
        "\($0.map { FieldAccessorTemplate($0) }, separator: "\n")"
      })
    \(if: !selections.merged.fields.values.isEmpty, """
      \(selections.merged.fields.values.map { FieldAccessorTemplate($0) },
        separator: "\n")
      """)

    \(if: !(selections.direct?.typeCases.isEmpty ?? true) || !selections.merged.typeCases.isEmpty,
      """
      \(ifLet: selections.direct?.typeCases.values, {
          """
          \($0.map { TypeCaseAccessorTemplate($0) }, separator: "\n")
          """
        })
      \(ifLet: selections.merged.typeCases.values, {
          """
          \($0.map { TypeCaseAccessorTemplate($0) }, separator: "\n")
          """
        })

      """
    )
    \(ifLet: selections.direct?.fields.values.compactMap { $0 as? IR.EntityField }, {
        "\($0.map { render(field: $0) }, separator: "\n")"
      })
    """
  }

  private static let DataFieldAndInitializerTemplate = """
    public let data: DataDict
    public init(data: DataDict) { self.data = data }
    """

  private func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    "public static var __parentType: ParentType { .\(type.parentTypeEnumType)(\(schema.name).\(type.name).self) }"
  }

  private func SelectionsTemplate(_ selections: IR.DirectSelections) -> TemplateString {
    """
    public static var selections: [Selection] { [
      \(if: !selections.fields.values.isEmpty, """
        \(selections.fields.values.map { FieldSelectionTemplate($0) }),
        """)
      \(if: !selections.typeCases.values.isEmpty, """
        \(selections.typeCases.values.map { TypeCaseSelectionTemplate($0.typeInfo) }),
        """)
      \(if: !selections.fragments.values.isEmpty, """
        \(selections.fragments.values.map { FragmentSelectionTemplate($0) }),
        """)
    ] }
    """
  }

  private func FieldSelectionTemplate(_ field: IR.Field) -> TemplateString {
    """
    .field("\(field.name)", \(ifLet: field.alias, {"alias: \"\($0)\", "})\(field.type.rendered).self)
    """
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

  private func FieldAccessorTemplate(_ field: IR.Field) -> TemplateString {
    func template(withType type: String) -> TemplateString {
      """
      public var \(field.responseKey): \(type) { data["\(field.responseKey)"] }
      """
    }

    let type: String
    switch field {
    case let scalarField as IR.ScalarField:
      type = scalarField.type.rendered

    case let entityField as IR.EntityField:
      type = self.nameCache.selectionSetType(for: entityField)

    default:
      fatalError()
    }
    return template(withType: type)
  }

  private func TypeCaseAccessorTemplate(_ typeCase: IR.SelectionSet) -> TemplateString {
    """
    public var as\(typeCase.parentType.name): As\(typeCase.parentType.name)? { _asType() }
    """
  }

}

fileprivate class SelectionSetNameCache {
  private var generatedSelectionSetNames: [ObjectIdentifier: String] = [:]

  func selectionSetName(for field: IR.EntityField) -> String {
    let objectId = ObjectIdentifier(self)
    if let name = generatedSelectionSetNames[objectId] { return name }

    let name = field.computeGeneratedSelectionSetName()
    generatedSelectionSetNames[objectId] = name
    return name
  }

  func selectionSetType(for field: IR.EntityField) -> String {
    field.type.rendered(replacingNamedTypeWith: selectionSetName(for: field))
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

fileprivate extension GraphQLType {
  var rendered: String {
    rendered(containedInNonNull: false)
  }

  func rendered(replacingNamedTypeWith newTypeName: String) -> String {
    rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName)
  }

  private func rendered(
    containedInNonNull: Bool,
    replacingNamedTypeWith newTypeName: String? = nil
  ) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .scalar(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      let typeName = newTypeName ?? type.name

      return containedInNonNull ? typeName : "\(typeName)?"

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.rendered(containedInNonNull: true, replacingNamedTypeWith: newTypeName)

    case let .list(ofType):
      let inner = "[\(ofType.rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName))]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }
}

fileprivate extension IR.EntityField {

  var formattedFieldName: String {
    return StringInflector.default.singularize(responseKey.firstUppercased)
  }

  func computeGeneratedSelectionSetName() -> String {
    if selectionSet.selections.direct != nil {
      return formattedFieldName
    }

    if selectionSet.selections.merged.mergedSources.count == 1 {
      return selectionSet.selections.merged.mergedSources
        .first.unsafelyUnwrapped
        .generatedSelectionSetName(for: self)
    }

    return formattedFieldName
  }

}

fileprivate extension IR.MergedSelections.MergedSource {

  func generatedSelectionSetName(for field: IR.EntityField) -> String {
    if let fragment = fragment {
      return generatedSelectionSetNameForMergedEntity(in: fragment)
    }

    var fieldTypePathCurrentNode = field.selectionSet.typeInfo.typePath.last
    var sourceTypePathCurrentNode = typeInfo.typePath.last
    var nodesToSharedRoot = 0

    while fieldTypePathCurrentNode.value == sourceTypePathCurrentNode.value {
      guard let previousFieldNode = fieldTypePathCurrentNode.previous,
            let previousSourceNode = sourceTypePathCurrentNode.previous else {
              break
            }

      fieldTypePathCurrentNode = previousFieldNode
      sourceTypePathCurrentNode = previousSourceNode
      nodesToSharedRoot += 1
    }

    let fieldPath = Array(typeInfo.entity.fieldPath
                            .toArray()
                            .suffix(nodesToSharedRoot + 1))

    let selectionSetName = generatedSelectionSetName(
      from: sourceTypePathCurrentNode,
      withFieldPath: fieldPath,
      removingFirst: nodesToSharedRoot <= 1
    )

    return selectionSetName
  }

  private func generatedSelectionSetNameForMergedEntity(in fragment: IR.FragmentSpread) -> String {
    var fragmentTypePathCurrentNode = fragment.selectionSet.typeInfo.typePath.head
    var sourceTypePathCurrentNode = typeInfo.typePath.head
    var nodesToFragment = 0

    while let nextNode = fragmentTypePathCurrentNode.next {
      fragmentTypePathCurrentNode = nextNode
      sourceTypePathCurrentNode = sourceTypePathCurrentNode.next!
      nodesToFragment += 1
    }

    let fieldPath = Array(typeInfo.entity.fieldPath.toArray().suffix(from: nodesToFragment + 1))
    let selectionSetName = generatedSelectionSetName(
      from: sourceTypePathCurrentNode.next!,
      withFieldPath: fieldPath
    )

    return "\(fragment.definition.name).\(selectionSetName)"
  }

  private func generatedSelectionSetName(
    from typePathNode: LinkedList<TypeScopeDescriptor>.Node,
    withFieldPath fieldPath: [String],
    removingFirst: Bool = false
  ) -> String {
    var currentNode = Optional(typePathNode)
    var fieldPathIndex = 0

    var components: [String] = []

    repeat {
      let fieldName = fieldPath[fieldPathIndex]
      components.append(StringInflector.default.singularize(fieldName.firstUppercased))

      var currentTypeScopeNode = currentNode.unsafelyUnwrapped.value.typePath.head
      while let typeCaseNode = currentTypeScopeNode.next {
        components.append("As\(typeCaseNode.value.name.firstUppercased)")
        currentTypeScopeNode = typeCaseNode
      }

      fieldPathIndex += 1
      currentNode = currentNode.unsafelyUnwrapped.next
    } while currentNode !== nil

    if removingFirst { components.removeFirst() }

    return components.joined(separator: ".")
  }

}
