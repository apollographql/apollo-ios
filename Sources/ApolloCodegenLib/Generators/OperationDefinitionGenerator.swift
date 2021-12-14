import ApolloAPI
import OrderedCollections

enum OperationDefinitionGenerator {

//  static let templates = [
//    "documentType": DocumentType.template
//  ]
//  static let environment = Environment(loader: DictionaryLoader(templates: templates))
//
//  static func render(
//    operation: CompilationResult.OperationDefinition,
//    in schema: IR.Schema,
//    config: ApolloCodegenConfiguration
//  ) throws -> String {
//    let context: [String: Any] = [
//      "schema": schema,
//      "operation": operation,
//      "config": config
//    ]
//    return try environment.renderTemplate(string: template, context: context)
//  }
//
//  private static let template =
//  """
//  query \(operation.name) {
//    \(indented: OperationDefinition.DocumentType.render(operation: operation)
//  }
//  """

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

      return """
      public let document: DocumentType = .notPersisted(
        \(if: apq != .disabled,
        "operationIdentifier: \(operation.operationIdentifier),"
        )
        definition: .init(
        ""\"
        \(operation.source)
        ""\"\(if: includeFragments, ",")
        \(if: includeFragments, Template("""
        fragments: [\(referencedFragments.map { "\($0.name).self" }, separator: ", ")]
        """))
      ))
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

}
