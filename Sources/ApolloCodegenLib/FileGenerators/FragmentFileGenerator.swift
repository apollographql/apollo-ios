import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments).
struct FragmentFileGenerator {
  /// Converts `graphQLFragment` into Swift code and writes the results to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLFragment: The `IR.NamedFragment` object used to build the file content.
  ///   - schema: The `IR.Schema` the fragment is belongs to.
  ///   - config: `ApolloCodegenConfiguration` object that defines behavior for the Swift code generation.
  ///   - directoryPath: The output path that the file will be written to.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphqlFragment: IR.NamedFragment,
    schema: IR.Schema,
    config: ApolloCodegenConfiguration.FileOutput,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphqlFragment.definition.name).swift").path

    let data = FragmentTemplate(
      fragment: graphqlFragment,
      schema: schema,
      config: config
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
