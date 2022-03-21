import ApolloUtils

struct EnumTemplate: TemplateRenderer {
  let graphqlEnum: GraphQLEnumType

  var template: TemplateString {
    TemplateString(
    """
    public enum \(graphqlEnum.name.firstUppercased): String, EnumType {
      \(graphqlEnum.values.map({
        "case \($0.name)"
      }), separator: "\n")
    }
    """
    )
  }
}
