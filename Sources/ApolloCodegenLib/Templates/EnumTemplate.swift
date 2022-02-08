struct EnumTemplate {
  let graphqlEnum: GraphQLEnumType

  func render() -> String {
    TemplateString(
    """
    \(HeaderCommentTemplate.render())

    \(ImportStatementTemplate.SchemaType.render())

    public enum \(graphqlEnum.name.firstUppercased): String, EnumType {
      \(graphqlEnum.values.map({
        "case \($0.name)"
      }), separator: "\n")
    }
    """
    ).description
  }
}
