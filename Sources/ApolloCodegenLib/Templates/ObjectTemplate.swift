import Foundation

struct ObjectTemplate {
  let graphqlObject: GraphQLObjectType

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.SchemaType.render())
    
    public final class \(graphqlObject.name.firstUppercased): Object {
      override public class var __typename: String { \"\(graphqlObject.name.firstUppercased)\" }

      override public class var __metadata: Metadata { _metadata }
      private static let _metadata: Metadata = Metadata(implements: [
        \(graphqlObject.interfaces.map({ interface in
      "\(interface.name.firstUppercased).self"
        }), separator: ",\n")
      ])
    }
    """).description
  }
}
