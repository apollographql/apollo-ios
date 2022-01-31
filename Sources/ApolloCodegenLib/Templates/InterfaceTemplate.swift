import Foundation

struct InterfaceTemplate {
  let graphqlInterface: GraphQLInterfaceType

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.SchemaType.render())

    public final class \(graphqlInterface.name): Interface { }
    """
    ).description
  }
}
