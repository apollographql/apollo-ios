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
}
