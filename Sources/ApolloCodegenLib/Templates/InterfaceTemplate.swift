import Foundation

struct InterfaceTemplate {
  let graphqlInterface: GraphQLInterfaceType

  func render() -> String {
    TemplateString(
    """
    public final class \(graphqlInterface.name): Interface { }
    """
    ).value
  }
}
