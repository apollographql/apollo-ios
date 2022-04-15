import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
struct EnumFileGenerator: FileGenerator {
  /// Source GraphQL enum.
  let graphqlEnum: GraphQLEnumType

  var template: TemplateRenderer { EnumTemplate(graphqlEnum: graphqlEnum) }
  var target: FileTarget { .enum }
  var fileName: String { "\(graphqlEnum.name).swift" }
}
