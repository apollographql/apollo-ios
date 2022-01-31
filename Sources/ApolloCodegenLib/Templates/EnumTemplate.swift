struct EnumTemplate {
  let graphqlEnum: GraphQLEnumType

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.SchemaType.render())

    public enum \(graphqlEnum.name): String, EnumType {
      \(graphqlEnum.values.map({
        "case \($0.name)"
      }), separator: "\n")
    }
    """
    ).description
  }
}
