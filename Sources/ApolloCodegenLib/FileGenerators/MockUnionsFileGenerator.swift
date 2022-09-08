import Foundation
import OrderedCollections

/// Generates a file providing the ability to mock the GraphQLUnionTypes in a schema
/// for testing purposes.
struct MockUnionsFileGenerator: FileGenerator {

  let graphQLUnions: OrderedSet<GraphQLUnionType>

  let config: ApolloCodegen.ConfigurationContext

  init?(ir: IR, config: ApolloCodegen.ConfigurationContext) {
    let unions = ir.schema.referencedTypes.unions
    guard !unions.isEmpty else { return nil }
    self.graphQLUnions = unions
    self.config = config
  }

  var template: TemplateRenderer {
    MockUnionsTemplate(
      graphQLUnions: graphQLUnions,
      config: config
    )
  }

  var target: FileTarget { .testMock }
  var fileName: String { "MockObject+Unions" }
}
