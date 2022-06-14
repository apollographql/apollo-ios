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
  
  var template: TemplateRenderer {
    irOperation.definition.isLocalCacheMutation ?
    LocalCacheMutationDefinitionTemplate(
      operation: irOperation,
      schema: schema,
      config: config
    ) :
    OperationDefinitionTemplate(
      operation: irOperation,
      schema: schema,
      config: config
    )
  }

  var target: FileTarget { .operation(irOperation.definition) }
  var fileName: String { "\(irOperation.definition.nameWithSuffix).swift" }
}
