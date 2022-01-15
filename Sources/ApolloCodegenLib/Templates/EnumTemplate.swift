struct EnumTemplate {
  let graphqlEnum: GraphQLEnumType

  func render() -> String {
    TemplateString(
    """
    public enum \(graphqlEnum.name): String, CaseIterable {
      \(graphqlEnum.values.map({
        "case \($0.name)"
      }), separator: "\n")
    }
    """
    ).value
  }
}
