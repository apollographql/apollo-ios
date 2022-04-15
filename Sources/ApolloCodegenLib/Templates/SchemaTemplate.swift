import Foundation

/// Provides the format to define a schema in Swift code. The schema represents metadata used by
/// the GraphQL executor at runtime to convert response data into corresponding Swift types.
struct SchemaTemplate: TemplateRenderer {
  // IR representation of source GraphQL schema.
  let schema: IR.Schema

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    public typealias ID = String

    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == \(schema.name.firstUppercased).Schema {}
    
    public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == \(schema.name.firstUppercased).Schema {}

    public enum Schema: SchemaConfiguration {
      public static func objectType(forTypename __typename: String) -> Object.Type? {
        switch __typename {
        \(schema.referencedTypes.objects.map {
          "case \"\($0.name.firstUppercased)\": return \(schema.name.firstUppercased).\($0.name.firstUppercased).self"
        }, separator: "\n")
        default: return nil
        }
      }
    }
    """
    )
  }
}
