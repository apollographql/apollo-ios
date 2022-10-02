import OrderedCollections

/// Provides the format to convert a [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations)
/// into Swift code.
struct OperationDefinitionTemplate: OperationTemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation
  /// IR representation of source GraphQL schema.
  let schema: IR.Schema

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
        apq: config.options.apqs,
        queryStringLiteralFormat: config.options.queryStringLiteralFormat
      ))

      \(section: VariableProperties(operation.definition.variables))

      \(Initializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables))

      \(SelectionSetTemplate(schema: schema, config: config).render(for: operation))
    }

    """)
  }

  private func OperationDeclaration(_ operation: CompilationResult.OperationDefinition) -> TemplateString {
    return """
    \(embeddedAccessControlModifier)\
    class \(operation.nameWithSuffix.firstUppercased): \(operation.operationType.renderedProtocolName) {
      public static let operationName: String = "\(operation.name)"
    """
  }

  enum DocumentType {
    static func render(
      _ operation: CompilationResult.OperationDefinition,
      identifier: @autoclosure () -> String,
      fragments: OrderedSet<IR.NamedFragment>,
      apq: ApolloCodegenConfiguration.APQConfig,
      queryStringLiteralFormat: ApolloCodegenConfiguration.QueryStringLiteralFormat
    ) -> TemplateString {
      let includeFragments = !fragments.isEmpty
      let includeDefinition = apq != .persistedOperationsOnly

      return TemplateString("""
      public static let document: DocumentType = .\(apq.rendered)(
      \(if: apq != .disabled, """
        operationIdentifier: \"\(identifier())\"\(if: includeDefinition, ",")
      """)
      \(if: includeDefinition, """
        definition: .init(
          \(operation.source.formatted(for: queryStringLiteralFormat))\(if: includeFragments, ",")
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
        ""\"
        \(self)
        ""\"
        """

    case .singleLine:
      return "\"\(components(separatedBy: .newlines).joined(separator: ""))\""
    }
  }
}
