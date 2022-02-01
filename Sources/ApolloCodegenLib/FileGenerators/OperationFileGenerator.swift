import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Operation](https://spec.graphql.org/draft/#sec-Language.Operations).
struct OperationFileGenerator {
  /// Converts `graphQLOperation` into Swift code and writes the result to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLOperation: `IR.Operation` object used to build the file content.
  ///   - schema: `IR.Schema` on which the operation executes.
  ///   - config: `ApolloCodegenConfiguration` object that defines behavior for the Swift code generation.
  ///   - directoryPath: Output path that the file will be written to.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphQLOperation: IR.Operation,
    schema: IR.Schema,
    config: ApolloCodegenConfiguration,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphQLOperation.definition.name).swift").path

    let data = OperationDefinitionTemplate(
      operation: graphQLOperation,
      schema: schema,
      config: config
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
