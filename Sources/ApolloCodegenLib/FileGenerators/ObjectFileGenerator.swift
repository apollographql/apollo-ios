import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
struct ObjectFileGenerator: FileGenerator {
  /// Source GraphQL object.
  let graphqlObject: GraphQLObjectType
  /// Shared codegen configuration.
  let config: ApolloCodegen.ConfigurationContext
  
  var template: TemplateRenderer {
    ObjectTemplate(graphqlObject: graphqlObject, config: config)
  }

  var target: FileTarget { .object }
  var fileName: String { graphqlObject.name }
}
