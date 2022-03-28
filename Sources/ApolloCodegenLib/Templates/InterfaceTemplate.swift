import Foundation

struct InterfaceTemplate: TemplateRenderer {
  let graphqlInterface: GraphQLInterfaceType

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    \(HeaderCommentTemplate.render())

    \(ImportStatementTemplate.SchemaType.render())

    public final class \(graphqlInterface.name): Interface { }
    """
    )
  }
}
