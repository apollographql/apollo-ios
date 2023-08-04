@testable import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  public static func mock(
    schemaNamespace: String = "TestSchema",
    input: FileInput = .init(
      schemaPath: "**/*.graphqls",
      operationSearchPaths: []
    ),
    output: FileOutput = .init(
      schemaTypes: .init(
        path: "MockSchemaTypes",
        moduleType: .embeddedInTarget(name: "MockApplication")
      )
    ),
    options: OutputOptions = .init(schemaDocumentation: .exclude),
    experimentalFeatures: ExperimentalFeatures = .init(),
    operationManifestConfiguration: OperationManifestConfiguration = .init(operationDocumentFormat: [.definition])
  ) -> Self {
    .init(
      schemaNamespace: schemaNamespace,
      input: input,
      output: output,
      options: options,
      experimentalFeatures: experimentalFeatures,
      operationManifestConfiguration: operationManifestConfiguration
    )
  }

  public static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    options: ApolloCodegenConfiguration.OutputOptions = .init(),
    schemaNamespace: String = "TestSchema",
    to path: String = "MockModulePath"
  ) -> Self {
    .init(
      schemaNamespace: schemaNamespace,
      input: .init(
        schemaPath: "schema.graphqls",
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: path, moduleType: moduleType)
      ),
      options: options
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
