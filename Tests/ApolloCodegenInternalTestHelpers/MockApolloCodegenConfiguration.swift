@testable import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  public static func mock(
    schemaName: String = "TestSchema",
    input: FileInput = .init(
      schemaPath: "MockSchemaPath",
      operationSearchPaths: []
    ),
    output: FileOutput = .init(
      schemaTypes: .init(
        path: "MockSchemaTypes",
        moduleType: .embeddedInTarget(name: "MockApplication")
      )
    ),
    options: OutputOptions = .init(schemaDocumentation: .exclude)
  ) -> Self {
    .init(schemaName: schemaName, input: input, output: output, options: options)
  }

  public static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    warningsOnDeprecatedUsage: ApolloCodegenConfiguration.Composition = .exclude,
    schemaName: String = "TestSchema",
    to path: String = "MockModulePath"
  ) -> Self {
    .init(
      schemaName: schemaName,
      input: .init(
        schemaPath: "schema.graphqls",
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: path, moduleType: moduleType)
      ),
      options: .init(
        warningsOnDeprecatedUsage: warningsOnDeprecatedUsage
      )
    )
  }
}

extension ApolloCodegenConfiguration.FileOutput {
  public static func mock(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .embeddedInTarget(name: "MockApplication"),
    operations: ApolloCodegenConfiguration.OperationsFileOutput = .relative(subpath: nil),
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput = .none,
    path: String = ""
  ) -> Self {
    .init(
      schemaTypes: .init(
        path: path,
        moduleType: moduleType
      ),
      operations: operations,
      testMocks: testMocks
    )
  }
}
