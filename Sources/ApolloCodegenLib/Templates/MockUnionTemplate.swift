import Foundation
import ApolloUtils

struct MockUnionTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
  let graphqlUnion: GraphQLUnionType

  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let ir: IR

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    TemplateString("""
    extension \
    \(if: !config.output.schemaTypes.isInModule, "\(ir.schema.name.firstUppercased).")\
    \(graphqlUnion.name.firstUppercased): MockFieldValue {
      public typealias MockValueCollectionType = Array<AnyMock>
    }
    """)
  }
}
