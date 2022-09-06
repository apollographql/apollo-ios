import OrderedCollections

struct LocalCacheMutationDefinitionTemplate: OperationTemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation
  /// IR representation of source GraphQL schema.
  let schema: IR.Schema

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    TemplateString(
    """
    \(embeddedAccessControlModifier)\
    class \(operation.definition.nameWithSuffix.firstUppercased): LocalCacheMutation {
      public static let operationType: GraphQLOperationType = .\(operation.definition.operationType.rawValue)

      \(section: VariableProperties(operation.definition.variables))

      \(if: !operation.definition.variables.allSatisfy(variableIsNonNull), "@_disfavoredOverload")
      \(Initializer(operation.definition.variables))
      \(if: config.options.embedNullableVariableConvenienceInitializer.shouldEmbed, NullishConvenienceInitializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables))

      \(SelectionSetTemplate(schema: schema, mutable: true, config: config).render(for: operation))
    }
    
    """)
  }

}
