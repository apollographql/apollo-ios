import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
struct InterfaceFileGenerator {
  /// Converts `graphQLInterface` into Swift code and writes the result to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLInterface: The `GraphQLInterfaceType` object used to build the file content.
  ///   - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphQLInterface: GraphQLInterfaceType,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphQLInterface.name).swift").path

    let data = InterfaceTemplate(
      graphqlInterface: graphQLInterface
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
