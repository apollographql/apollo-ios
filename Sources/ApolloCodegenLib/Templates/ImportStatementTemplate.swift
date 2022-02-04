struct ImportStatementTemplate {
  static let template: StaticString =
    """
    import ApolloAPI
    """

  enum SchemaType {
    static func render() -> String {
      template.description
    }
  }

  enum Operation {
    static func render(_ config: ApolloCodegenConfiguration.FileOutput) -> TemplateString {
      """
      \(template.description)
      \(if: shouldImportSchemaModule(config), "import \(config.schemaTypes.moduleName)")
      """
    }

    private static func shouldImportSchemaModule(
      _ config: ApolloCodegenConfiguration.FileOutput
    ) -> Bool {
      config.operations != .inSchemaModule && config.schemaTypes.isInModule
    }
  }
}

fileprivate extension ApolloCodegenConfiguration.SchemaTypesFileOutput {
  var isInModule: Bool {
    switch dependencyAutomation {
    case .manuallyLinked: return false
    case .swiftPackageManager, .cocoaPods, .carthage: return true
    }
  }
}
