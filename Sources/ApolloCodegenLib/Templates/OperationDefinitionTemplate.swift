import OrderedCollections
import ApolloUtils

/// Provides the format to convert a [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations)
/// into Swift code.
struct OperationDefinitionTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
  let operation: IR.Operation
  /// IR representation of source GraphQL schema.
  let schema: IR.Schema
  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    TemplateString(
    """
    \(OperationDeclaration(operation.definition))
      \(DocumentType.render(
        operation.definition,
        fragments: operation.referencedFragments,
        apq: config.options.apqs)
      )

      \(section: VariableProperties(operation.definition.variables))

      \(Initializer(operation.definition.variables))

      \(section: VariableAccessors(operation.definition.variables))

      \(SelectionSetTemplate(schema: schema).render(for: operation))
    }
    """)
  }

  private func OperationDeclaration(_ operation: CompilationResult.OperationDefinition) -> TemplateString {
    return """
    public class \(operation.nameWithSuffix.firstUppercased): \(operation.operationType.renderedProtocolName) {
      public let operationName: String = "\(operation.name)"
    """
  }

  enum DocumentType {
    static func render(
      _ operation: CompilationResult.OperationDefinition,
      fragments: OrderedSet<IR.NamedFragment>,
      apq: ApolloCodegenConfiguration.APQConfig
    ) -> TemplateString {
      let includeFragments = !fragments.isEmpty
      let includeDefinition = apq != .persistedOperationsOnly

      return TemplateString("""
      public let document: DocumentType = .\(apq.rendered)(
      \(if: apq != .disabled, """
        operationIdentifier: \"\(operation.operationIdentifier)\"\(if: includeDefinition, ",")
      """)
      \(if: includeDefinition, """
        definition: .init(
          ""\"
          \(operation.source)
          ""\"\(if: includeFragments, ",")
          \(if: includeFragments,
                            "fragments: [\(fragments.map { "\($0.name).self" }, separator: ", ")]")
        ))
      """,
      else: """
      )
      """)
      """
      )
    }
  }

  private func Initializer(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    let `init` = "public init"
    if variables.isEmpty {
      return "\(`init`)() {}"
    }

    return """
    \(`init`)(\(list: variables.map(VariableParameter))) {
      \(variables.map { "self.\($0.name) = \($0.name)" }, separator: "\n")
    }
    """
  }


  func VariableProperties(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    """
    \(variables.map { "public var \($0.name): \($0.type.renderAsInputValue(in: schema))"}, separator: "\n")
    """
  }

  func VariableParameter(_ variable: CompilationResult.VariableDefinition) -> TemplateString {
      """
      \(variable.name): \(variable.type.renderAsInputValue(in: schema))\
      \(if: variable.defaultValue != nil, " = " + variable.renderVariableDefaultValue())
      """
  }

  func VariableAccessors(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    guard !variables.isEmpty else {
      return ""
    }

    return """
      public var variables: Variables? {
        [\(variables.map { "\"\($0.name)\": \($0.name)"}, separator: ",\n   ")]
      }
      """
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
