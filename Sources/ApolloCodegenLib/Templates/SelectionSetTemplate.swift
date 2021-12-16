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
    \(SelectionsTemplate(field.selectionSet.selections))
    """
  }

  private static let DataFieldAndInitializerTemplate = """
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }
    """

  private func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    "public static var __parentType: ParentType { .\(type.parentTypeEnumType)(\(schema.name).\(type.name).self) }"
  }

  private func SelectionsTemplate(_ selections: IR.SortedSelections) -> TemplateString {
    """
    public static var selections: [Selection] { [
      \(selections.fields.values.map {
        FieldSelectionTemplate($0)
      }),
    ] }
    """
  }

  private func FieldSelectionTemplate(_ field: IR.Field) -> TemplateString {
    """
    .field("\(field.name)", \(field.type.rendered).self)
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
      return "[\(ofType.rendered(containedInNonNull: false))]"
    }
  }
}
