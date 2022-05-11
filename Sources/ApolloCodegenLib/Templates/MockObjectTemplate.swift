import Foundation

struct MockObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  let ir: IR

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    """
    public extension \(graphqlObject.name.firstUppercased): Mockable {
      public static let __mockFields = MockFields()
    
      public struct MockFields {
        \(ir.fieldCollector.collectedFields(for: graphqlObject).map { field -> String in
          let type = field.type.rendered(
            containedInNonNull: true,
            inSchemaNamed: ir.schema.name
          )
          return """
          @Field<\(type)>("\(field.name)") public var \(field.name)
          """
        }, separator: "\n")
      }
    }
    """
  }

  
}
