import ApolloUtils

struct ImportStatementTemplate {
  static let template: StaticString =
    """
    import ApolloAPI
    """

  enum SchemaType {
    static let template: StaticString = ImportStatementTemplate.template
  }

  enum Operation {
    static func template(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> TemplateString {
      """
      \(ImportStatementTemplate.template)
      \(if: shouldImportSchemaModule(config.output), "import \(config.output.schemaTypes.schemaName)")
      """
    }

    private static func shouldImportSchemaModule(
      _ config: ApolloCodegenConfiguration.FileOutput
    ) -> Bool {
      config.operations != .inSchemaModule && config.schemaTypes.isInModule
    }
  }
}
