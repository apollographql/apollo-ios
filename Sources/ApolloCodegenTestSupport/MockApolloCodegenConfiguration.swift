@testable import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  public static func mock(
    input: FileInput = .init(schemaPath: "MockSchemaPath", searchPaths: []),
    output: FileOutput = .init(schemaTypes: .init(path: "MockSchemaTypes")),
    additionalInflectionRules: [ApolloCodegenLib.InflectionRule] = [],
    queryStringLiteralFormat: QueryStringLiteralFormat = .multiline,
    customScalarFormat: CustomScalarFormat = .defaultAsString,
    deprecatedEnumCases: Composition = .include,
    schemaDocumentation: Composition = .include,
    apqs: APQConfig = .disabled
  ) -> Self {
    .init(
      input: input,
      output: output,
      additionalInflectionRules: additionalInflectionRules,
      queryStringLiteralFormat: queryStringLiteralFormat,
      customScalarFormat: customScalarFormat,
      deprecatedEnumCases: deprecatedEnumCases,
      schemaDocumentation: schemaDocumentation,
      apqs: apqs
    )
  }

  public static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    to path: String = "MockModulePath"
  ) -> Self {
    .init(
      input: .init(schemaPath: "schema.graphqls",
                   searchPaths: ["*.graphql"]),
      output: .init(schemaTypes: .init(path: path,
                                       dependencyAutomation: moduleType))
    )
  }
}

extension ApolloCodegenConfiguration.FileOutput {
  public static func mock(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType =
      .manuallyLinked(namespace: "MockSchemaTypes"),
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) -> Self {
    .init(
      schemaTypes: .init(
        path: "",
        dependencyAutomation: moduleType
      ),
      operations: operations
    )
  }
}
