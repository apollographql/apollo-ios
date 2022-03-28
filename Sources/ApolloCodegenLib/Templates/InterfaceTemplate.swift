import Foundation

struct InterfaceTemplate: TemplateRenderer {
  let graphqlInterface: GraphQLInterfaceType

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    public final class \(graphqlInterface.name): Interface { }
    """
    )
  }
}
