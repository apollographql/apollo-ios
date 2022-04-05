import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
struct OperationFileGenerator: FileGenerator {
  /// Source IR operation.
  let irOperation: IR.Operation
  /// Source IR schema.
  let schema: IR.Schema
  /// Shared codegen configuration
  let config: ReferenceWrapped<ApolloCodegenConfiguration>
  
  var template: TemplateRenderer { OperationDefinitionTemplate(
    operation: irOperation,
    schema: schema,
    config: config
  ) }
  var target: FileTarget { .operation(irOperation.definition) }
  var fileName: String { "\(irOperation.definition.nameWithSuffix).swift" }
}
