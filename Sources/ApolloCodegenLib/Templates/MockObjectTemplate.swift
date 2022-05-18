import Foundation
import ApolloUtils

struct MockObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let ir: IR

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    let objectName = graphqlObject.name.firstUppercased
    let fields: [(name: String, type: String)] = ir.fieldCollector
      .collectedFields(for: graphqlObject)
      .map {
        (
          name: $0.0,
          type: $0.1.rendered(containedInNonNull: true, inSchemaNamed: ir.schema.name)
        )
      }

    return """
    public extension \
    \(if: !config.output.schemaTypes.isInModule, "\(ir.schema.name.firstUppercased).")\
    \(objectName): Mockable {
      public static let __mockFields = MockFields()
    
      public struct MockFields {
        \(fields.map {
          return """
          @Field<\($0.type)>("\($0.name)") public var \($0.name)
          """
        }, separator: "\n")
      }
    }

    public extension Mock where O == \(objectName) {
      public convenience init(
        \(fields.map { "\($0.name): \($0.type)? = nil" }, separator: ",\n")
      ) {
        self.init()
        \(fields.map { "self.\($0.name) = \($0.name)" }, separator: "\n")
      }
    }
    """
  }

  
}
