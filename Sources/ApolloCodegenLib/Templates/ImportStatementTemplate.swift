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
    static func render(_ config: ApolloCodegenConfiguration) -> TemplateString {
      """
      \(template.description)
      \(if: shouldImportSchemaModule(config), "import \(config.output.schemaTypes.moduleName)")
      """
    }

    private static func shouldImportSchemaModule(_ config: ApolloCodegenConfiguration) -> Bool {
      config.output.operations != .inSchemaModule && config.output.schemaTypes.isInModule
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
