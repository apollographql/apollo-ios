import Foundation

/// Provides the format to convert a [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects)
/// into Swift code.
struct ObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  let ir: IR

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    let collectedFields = ir.fieldCollector.collectedFields(for: graphqlObject)

    return TemplateString(
    """
    public final class \(graphqlObject.name.firstUppercased): Object {
      override public class var __typename: StaticString { \"\(graphqlObject.name.firstUppercased)\" }

      \(section: MetadataTemplate(covariantFields: collectedFields.covariantFields))

      \(section: SchemaTypeFieldsTemplate.render(fields: collectedFields.0, schemaName: ir.schema.name))
    
    }
    """)
  }

  private func MetadataTemplate(covariantFields: Set<GraphQLField>) -> TemplateString {
    guard !graphqlObject.interfaces.isEmpty else {
      return ""
    }

    return """
    override public class var __metadata: Metadata { _metadata }
    private static let _metadata: Metadata = Metadata(
      implements: [
        \(graphqlObject.interfaces.map({ interface in
          "\(interface.name.firstUppercased).self"
      }), separator: ",\n")
      ]\(if: !covariantFields.isEmpty, """
    ,
      covariantFields: [
        \(covariantFields.map {
          "\"\($0.name)\": \($0.type.innerType.rendered(containedInNonNull: true, inSchemaNamed: ir.schema.name)).self"
        })
      ]
    """)
    )
    """
  }
}
