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

  func BodyTemplate(_ field: IR.EntityField) -> TemplateString {
    """
    \(Self.DataFieldAndInitializerTemplate)

    \(ParentTypeTemplate(field.selectionSet.parentType))
    """
  }

  static let DataFieldAndInitializerTemplate = """
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }
    """

  func ParentTypeTemplate(_ type: GraphQLCompositeType) -> String {
    "public static var __parentType: ParentType { .\(type.parentTypeEnumType)(\(schema.name).\(type.name).self) }"
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
