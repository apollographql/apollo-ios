import Foundation
import ApolloUtils

/// Generates a file providing the ability to mock a GraphQLUnionType for testing purposes.
struct MockUnionFileGenerator: FileGenerator {
  /// Source GraphQL union.
  let graphqlUnion: GraphQLUnionType

  let ir: IR

  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  var template: TemplateRenderer {
    MockUnionTemplate(
      graphqlUnion: graphqlUnion,
      config: config,
      ir: ir
    )
  }

  var target: FileTarget { .testMock }
  var fileName: String { "\(graphqlUnion.name)+Mock.swift" }
}
