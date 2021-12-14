import ApolloAPI

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
      apq: ApolloCodegenConfiguration.APQConfig
    ) -> Template {
      """
      public let document: DocumentType = .notPersisted(
        \(if: apq != .disabled,
        "operationIdentifier: \(operation.operationIdentifier),"
        )
        definition: .init(
        ""\"
        \(operation.source)
        ""\"))
      """
    }
  }
}

extension ApolloCodegenConfiguration.APQConfig {

}
