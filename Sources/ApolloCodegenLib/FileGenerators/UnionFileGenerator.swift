import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
struct UnionFileGenerator {
  /// Converts `graphQLUnion` into Swift code and writes the result to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLUnion: The `GraphQLUnionType` object used to build the file content.
  ///   - moduleName: The name of the generated Swift code module.
  ///   - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphQLUnion: GraphQLUnionType,
    moduleName: String,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphQLUnion.name).swift").path

    let data = UnionTemplate(
      moduleName: moduleName,
      graphqlUnion: graphQLUnion
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
