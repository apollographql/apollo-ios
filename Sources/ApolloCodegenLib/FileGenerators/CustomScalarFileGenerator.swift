import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Custom Scalar](https://spec.graphql.org/draft/#sec-Scalars.Custom-Scalars).
struct CustomScalarFileGenerator: FileGenerator {
  /// Source GraphQL Custom Scalar..
  let graphqlScalar: GraphQLScalarType

  var template: TemplateRenderer { CustomScalarTemplate(graphqlScalar: graphqlScalar) }
  var target: FileTarget { .customScalar }
  var fileName: String { "\(graphqlScalar.name).swift" }
  var overwrite: Bool { false }
}
