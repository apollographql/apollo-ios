import Foundation

/// Provides the format to convert a [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects)
/// into Swift code.
struct ObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    public final class \(graphqlObject.name.firstUppercased): Object {
      override public class var __typename: StaticString { \"\(graphqlObject.name.firstUppercased)\" }

      override public class var __metadata: Metadata { _metadata }
      private static let _metadata: Metadata = Metadata(implements: [
        \(graphqlObject.interfaces.map({ interface in
      "\(interface.name.firstUppercased).self"
        }), separator: ",\n")
      ])
    }
    """)
  }
}
