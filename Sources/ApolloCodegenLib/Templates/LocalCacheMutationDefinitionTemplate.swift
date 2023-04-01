import OrderedCollections

struct LocalCacheMutationDefinitionTemplate: OperationTemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    let definition = IR.Definition.operation(operation)

    return TemplateString(
    """
    \(embeddedAccessControlModifier(target: target))\
    class \(operation.generatedDefinitionName): LocalCacheMutation {
      public static let operationType: GraphQLOperationType = .\(operation.definition.operationType.rawValue)

      \(section: VariableProperties(operation.definition.variables))

      \(Initializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables, graphQLOperation: false))

      public struct Data: \(definition.renderedSelectionSetType(config)) {
        \(SelectionSetTemplate(
            definition: definition,            
            generateInitializers: config.options.shouldGenerateSelectionSetInitializers(for: operation),
            config: config,
            accessControlRenderer: { embeddedAccessControlModifier(target: target) }()
        ).renderBody())
      }
    }
    
    """)
  }

}
