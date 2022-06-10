import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Custom Scalar](https://spec.graphql.org/draft/#sec-Scalars.Custom-Scalars).
struct CustomScalarFileGenerator: FileGenerator {
  /// Source GraphQL Custom Scalar..
  let graphqlScalar: GraphQLScalarType
  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  var template: TemplateRenderer {
    CustomScalarTemplate(graphqlScalar: graphqlScalar, config: config)
  }

  var target: FileTarget { .customScalar }
  var fileName: String { "\(graphqlScalar.name).swift" }
  var overwrite: Bool { false }
}
