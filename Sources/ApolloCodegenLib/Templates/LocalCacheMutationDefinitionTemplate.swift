import OrderedCollections

struct LocalCacheMutationDefinitionTemplate: OperationTemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    let definition = IR.Definition.operation(operation)
    let memberAccessControl = accessControlModifier(for: .member, in: target)

    return TemplateString(
    """
    \(accessControlModifier(for: .parent, in: target))\
    class \(operation.generatedDefinitionName): LocalCacheMutation {
      \(memberAccessControl)static let operationType: GraphQLOperationType = .\(operation.definition.operationType.rawValue)

      \(section: VariableProperties(operation.definition.variables))

      \(Initializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables, graphQLOperation: false))

      \(memberAccessControl)struct Data: \(definition.renderedSelectionSetType(config)) {
        \(SelectionSetTemplate(
            definition: definition,            
            generateInitializers: config.options.shouldGenerateSelectionSetInitializers(for: operation),
            config: config,
            accessControlRenderer: { accessControlModifier(for: .member, in: target) }()
        ).renderBody())
      }
    }
    
    """)
  }

}
