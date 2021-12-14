import ApolloAPI
import OrderedCollections

enum OperationDefinitionGenerator {

}

// MARK: - DocumentType

extension OperationDefinitionGenerator {
  enum DocumentType {
    static func render(
      operation: CompilationResult.OperationDefinition,
      referencedFragments: OrderedSet<CompilationResult.FragmentDefinition>,
      apq: ApolloCodegenConfiguration.APQConfig
    ) -> Template {
      let includeFragments = !referencedFragments.isEmpty
      let includeDefinition = apq != .persistedOperationsOnly

      return """
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
          "fragments: [\(referencedFragments.map { "\($0.name).self" }, separator: ", ")]")
        ))
      """,
      else: """
      )
      """)
      """
    }

    private static func render(
      _ referencedFragments: OrderedSet<CompilationResult.FragmentDefinition>
    ) -> Template {
      ""
    }
  }
}

extension ApolloCodegenConfiguration.APQConfig {
  fileprivate var rendered: String {
    switch self {
    case .disabled: return "notPersisted"
    case .automaticallyPersist: return "automaticallyPersisted"
    case .persistedOperationsOnly: return "persistedOperationsOnly"
    }
  }
}
