import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
struct InterfaceFileGenerator: FileGenerator {
  /// Source GraphQL interface.
  let graphqlInterface: GraphQLInterfaceType
  /// Shared codegen configuration.
  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateRenderer {
    InterfaceTemplate(graphqlInterface: graphqlInterface, config: config)
  }

  var target: FileTarget { .interface }
  var fileName: String { graphqlInterface.name }
}
