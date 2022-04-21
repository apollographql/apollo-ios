@testable import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  public static func mock(
    input: FileInput = .init(schemaPath: "MockSchemaPath", searchPaths: []),
    output: FileOutput = .init(schemaTypes: .init(path: "MockSchemaTypes", schemaName: "MockSchemaTypes")),
    options: OutputOptions = .init()
  ) -> Self {
    .init(input: input, output: output, options: options)
  }

  public static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "MockSchemaTypes",
    to path: String = "MockModulePath"
  ) -> Self {
    .init(
      input: .init(schemaPath: "schema.graphqls",
                   searchPaths: ["*.graphql"]),
      output: .init(schemaTypes: .init(path: path,
                                       schemaName: schemaName,
                                       moduleType: moduleType))
    )
  }
}

extension ApolloCodegenConfiguration.FileOutput {
  public static func mock(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .none,
    schemaName: String = "MockSchemaTypes",
    operations: ApolloCodegenConfiguration.OperationsFileOutput,
    path: String = ""
  ) -> Self {
    .init(
      schemaTypes: .init(
        path: path,
        schemaName: schemaName,
        moduleType: moduleType
      ),
      operations: operations
    )
  }
}
