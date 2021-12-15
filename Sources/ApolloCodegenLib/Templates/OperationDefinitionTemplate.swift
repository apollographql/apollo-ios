import OrderedCollections

enum OperationDefinitionTemplate {

}

// MARK: - DocumentType

extension OperationDefinitionTemplate {
  enum DocumentType {
    static func render(
      operation: CompilationResult.OperationDefinition,
      referencedFragments: OrderedSet<CompilationResult.FragmentDefinition>,
      apq: ApolloCodegenConfiguration.APQConfig
    ) -> String {
      let includeFragments = !referencedFragments.isEmpty
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
          "fragments: [\(referencedFragments.map { "\($0.name).self" }, separator: ", ")]")
        ))
      """,
      else: """
      )
      """)
      """
      ).description
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
