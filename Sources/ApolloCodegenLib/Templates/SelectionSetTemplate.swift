import ApolloUtils
import InflectorKit

struct SelectionSetTemplate {

  let schema: IR.Schema

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
    """
    \(Self.DataFieldAndInitializerTemplate)

    \(ParentTypeTemplate(selectionSet.parentType))
    \(ifLet: selectionSet.selections.direct, { SelectionsTemplate($0) }, else: "\n")

    \(ifLet: selectionSet.selections.direct?.fields.values,
      where: { !$0.isEmpty }, {
        "\($0.map { FieldAccessorTemplate($0) }, separator: "\n")"
      })
    \(if: !selectionSet.selections.merged.fields.values.isEmpty, """
      \(selectionSet.selections.merged.fields.values.map { FieldAccessorTemplate($0) },
        separator: "\n")
      """)

    \(ifLet: selectionSet.selections.direct?.fields.values.compactMap { $0 as? IR.EntityField },
      where: { !$0.isEmpty }, {
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
      type = entityField.generatedSelectionSetType

    default:
      fatalError()
    }
    return template(withType: type)
  }

}

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

  var generatedSelectionSetName: String {
    if selectionSet.selections.direct != nil {
      return formattedFieldName
    }

    if selectionSet.selections.merged.mergedSources.count == 1 {
      return selectionSet.selections.merged.mergedSources
        .first.unsafelyUnwrapped
        .generatedSelectionSetName
    }

    return formattedFieldName
  }

  var generatedSelectionSetType: String {
    return self.type.rendered(replacingNamedTypeWith: generatedSelectionSetName)
  }

}

fileprivate extension IR.MergedSelections.MergedSource {
  var generatedSelectionSetName: String {
    guard let fragmentSource = fragment else {
      return typeInfo.debugDescription
    }

    var fragmentTypePathCurrentNode = fragmentSource.selectionSet.typeInfo.typePath.head
    var sourceTypePathCurrentNode = typeInfo.typePath.head
    var nodesToFragment = 1

    while let nextNode = fragmentTypePathCurrentNode.next {
      fragmentTypePathCurrentNode = nextNode
      sourceTypePathCurrentNode = sourceTypePathCurrentNode.next!
      nodesToFragment += 1
    }

    let fieldPath = Array(typeInfo.entity.fieldPath.toArray().suffix(from: nodesToFragment))
    let selectionSetName = generatedSelectionSetName(
      from: sourceTypePathCurrentNode.next!,
      withFieldPath: fieldPath
    )

    return "\(fragmentSource.definition.name).\(selectionSetName)"
  }

  private func generatedSelectionSetName(
    from typePathNode: LinkedList<TypeScopeDescriptor>.Node,
    withFieldPath fieldPath: [String]
  ) -> String {
    var currentNode: LinkedList<TypeScopeDescriptor>.Node? = typePathNode
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

    return components.joined(separator: ".")
  }

}
