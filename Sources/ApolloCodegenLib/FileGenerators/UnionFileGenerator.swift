import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
struct UnionFileGenerator: FileGenerator {
  /// Source GraphQL union.
  let graphqlUnion: GraphQLUnionType
  /// Shared codegen configuration.
  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateRenderer { UnionTemplate(
    graphqlUnion: graphqlUnion,
    config: config
  ) }
  var target: FileTarget { .union }
  var fileName: String { graphqlUnion.name }
}
