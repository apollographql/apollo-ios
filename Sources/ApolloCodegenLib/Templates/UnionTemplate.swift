import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions)
/// into Swift code.
struct UnionTemplate: TemplateRenderer {
  /// Module name.
  let moduleName: String
  /// IR representation of source [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
  let graphqlUnion: GraphQLUnionType
  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    \(embeddedAccessControlModifier(config: config) ?? "")\
    enum \(graphqlUnion.name.firstUppercased): Union {
      public static let possibleTypes: [Object.Type] = [
        \(graphqlUnion.types.map({ type in
          "\(moduleName.firstUppercased).\(type.name.firstUppercased).self"
        }), separator: ",\n")
      ]
    }
    """
    )
  }
}
