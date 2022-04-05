import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
struct UnionFileGenerator: FileGenerator {
  /// Source GraphQL union.
  let graphqlUnion: GraphQLUnionType
  /// Schema name
  let schemaName: String

  var template: TemplateRenderer { UnionTemplate(
    moduleName: schemaName,
    graphqlUnion: graphqlUnion
  ) }
  var target: FileTarget { .union }
  var fileName: String { "\(graphqlUnion.name).swift" }
}
