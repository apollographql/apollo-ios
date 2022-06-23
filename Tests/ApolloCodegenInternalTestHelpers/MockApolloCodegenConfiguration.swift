@testable import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  public static func mock(
    schemaName: String = "MockSchemaTypes",
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
    options: OutputOptions = .init()
  ) -> Self {
    .init(schemaName: schemaName, input: input, output: output, options: options)
  }

  public static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "MockSchemaTypes",
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
      )
    )
  }
}

extension ApolloCodegenConfiguration.FileOutput {
  public static func mock(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .embeddedInTarget(name: "MockApplication"),
    operations: ApolloCodegenConfiguration.OperationsFileOutput,
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
