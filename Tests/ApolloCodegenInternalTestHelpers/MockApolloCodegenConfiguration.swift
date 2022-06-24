@testable import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  public static func mock(
    schemaName: String = "TestSchema",
    input: FileInput = .init(
      schemaPath: "MockSchemaPath",
      searchPaths: []
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
    schemaName: String = "TestSchema",
    to path: String = "MockModulePath"
  ) -> Self {
    .init(
      schemaName: schemaName,
      input: .init(
        schemaPath: "schema.graphqls",
        searchPaths: ["*.graphql"]
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
