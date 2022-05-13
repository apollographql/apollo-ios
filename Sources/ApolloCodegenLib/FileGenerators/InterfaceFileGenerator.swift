import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
struct InterfaceFileGenerator: FileGenerator {
  /// Source GraphQL interface.
  let graphqlInterface: GraphQLInterfaceType

  var template: TemplateRenderer { InterfaceTemplate(graphqlInterface: graphqlInterface) }
  var target: FileTarget { .interface }
  var fileName: String { "\(graphqlInterface.name.firstUppercased).swift" }
}
