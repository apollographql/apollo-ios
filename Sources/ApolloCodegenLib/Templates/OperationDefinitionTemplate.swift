import OrderedCollections

/// Provides the format to convert a [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations)
/// into Swift code.
struct OperationDefinitionTemplate: OperationTemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    TemplateString(
    """
    \(OperationDeclaration(operation.definition))
      \(DocumentType.render(
        operation.definition,
        identifier: operation.operationIdentifier,
        fragments: operation.referencedFragments,
        config: config
      ))

      \(section: VariableProperties(operation.definition.variables))

      \(Initializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables))

      \(SelectionSetTemplate(
          generateInitializers: config.options.shouldGenerateSelectionSetInitializers(for: operation),
          config: config
      ).render(for: operation))
    }

    """)
  }

  private func OperationDeclaration(_ operation: CompilationResult.OperationDefinition) -> TemplateString {
    return """
    \(embeddedAccessControlModifier(target: target))\
    class \(operation.nameWithSuffix.firstUppercased): \(operation.operationType.renderedProtocolName) {
      public static let operationName: String = "\(operation.name)"
    """
  }

  enum DocumentType {
    static func render(
      _ operation: CompilationResult.OperationDefinition,
      identifier: @autoclosure () -> String,
      fragments: OrderedSet<IR.NamedFragment>,
      config: ApolloCodegen.ConfigurationContext
    ) -> TemplateString {
      let includeFragments = !fragments.isEmpty
      let includeDefinition = config.options.apqs != .persistedOperationsOnly

      return TemplateString("""
      public static let document: \(config.ApolloAPITargetName).DocumentType = .\(config.options.apqs.rendered)(
      \(if: config.options.apqs != .disabled, """
        operationIdentifier: \"\(identifier())\"\(if: includeDefinition, ",")
      """)
      \(if: includeDefinition, """
        definition: .init(
          \(operation.source.formatted(for: config.options.queryStringLiteralFormat))\(if: includeFragments, ",")
          \(if: includeFragments,
                            "fragments: [\(fragments.map { "\($0.name.firstUppercased).self" }, separator: ", ")]")
        ))
      """,
      else: """
      )
      """)
      """
      )
    }
  }

}

fileprivate extension ApolloCodegenConfiguration.APQConfig {
  var rendered: String {
    switch self {
    case .disabled: return "notPersisted"
    case .automaticallyPersist: return "automaticallyPersisted"
    case .persistedOperationsOnly: return "persistedOperationsOnly"
    }
  }
}

fileprivate extension CompilationResult.OperationType {
  var renderedProtocolName: String {
    switch self {
    case .query: return "GraphQLQuery"
    case .mutation: return "GraphQLMutation"
    case .subscription: return "GraphQLSubscription"
    }
  }
}

fileprivate extension String {
  func formatted(for format: ApolloCodegenConfiguration.QueryStringLiteralFormat) -> Self {
    switch format {
    case .multiline:
      return """
        #""\"
        \(self)
        ""\"#
        """

    case .singleLine:
      return "#\"\(components(separatedBy: .newlines).joined(separator: ""))\"#"
    }
  }
}
