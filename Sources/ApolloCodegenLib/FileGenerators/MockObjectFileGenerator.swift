import Foundation

/// Generates a file providing the ability to mock a GraphQLObject for testing purposes.
struct MockObjectFileGenerator: FileGenerator {
  /// Source GraphQL object.
  let graphqlObject: GraphQLObjectType

  let ir: IR

  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateRenderer {
    MockObjectTemplate(
      graphqlObject: graphqlObject,
      config: config,
      ir: ir
    )
  }

  var target: FileTarget { .testMock }
  var fileName: String { "\(graphqlObject.name)+Mock.swift" }
}
