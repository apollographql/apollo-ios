import OrderedCollections
import ApolloUtils

struct LocalCacheMutationDefinitionTemplate: OperationTemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation
  /// IR representation of source GraphQL schema.
  let schema: IR.Schema

  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    TemplateString(
    """
    \(embeddedAccessControlModifier)\
    class \(operation.definition.nameWithSuffix.firstUppercased): LocalCacheMutation {
      public static let operationType: GraphQLOperationType = .\(operation.definition.operationType.rawValue)

      \(section: VariableProperties(operation.definition.variables))

      \(Initializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables))

      \(SelectionSetTemplate(schema: schema, mutable: true, config: config).render(for: operation))
    }
    """)
  }

}
