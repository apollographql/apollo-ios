struct SelectionSetTemplate {

  let schema: IR.Schema

  func render(for operation: IR.Operation) -> String {
    TemplateString(
    """
    public struct Data: \(schema.name).SelectionSet {
      \(BodyTemplate(operation.rootField))
    """
    ).description
  }

  func render(for fragment: IR.NamedFragment) -> String {
    TemplateString(
    """
    public struct \(fragment.name): \(schema.name).SelectionSet, Fragment {
      \(BodyTemplate(fragment.rootField))
    """
    ).description
  }

  func render(field: IR.EntityField) -> String {
    TemplateString(
    """
    public struct TODO: \(schema.name).SelectionSet {
      \(BodyTemplate(field))
    """
    ).description
  }

  private func BodyTemplate(_ field: IR.EntityField) -> TemplateString {
    """
    \(Self.DataFieldAndInitializerTemplate)

    \(ParentTypeTemplate(field.selectionSet.parentType))
    \(ifLet: field.selectionSet.selections.direct, { SelectionsTemplate($0) })
    """
  }

  private static let DataFieldAndInitializerTemplate = """
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }
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

  private func rendered(containedInNonNull: Bool) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .scalar(type as GraphQLNamedType),
      let .enum(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      return containedInNonNull ? type.name : "\(type.name)?"

    case let .nonNull(ofType):
      return ofType.rendered(containedInNonNull: true)

    case let .list(ofType):
      let inner = "[\(ofType.rendered(containedInNonNull: false))]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }
}
