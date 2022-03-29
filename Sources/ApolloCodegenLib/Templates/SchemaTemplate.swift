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
    where Schema == \(schema.name).Schema {}
    
    public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
    where Schema == \(schema.name).Schema {}

    public enum Schema: SchemaConfiguration {
      public static func objectType(forTypename __typename: String) -> Object.Type? {
        switch __typename {
        \(schema.referencedTypes.objects.map {
        "case \"\($0.name)\": return \(schema.name).\($0.name).self"
        }, separator: "\n")
        default: return nil
        }
      }
    }
    """
    )
  }
}
