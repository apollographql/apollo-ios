import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
struct EnumFileGenerator {
  /// Converts `graphQLEnum` into Swift code and writes the result to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLEnum: The `GraphQLEnumType` object used to build the file content.
  ///   - directoryPath: The output path that the file will be written to.
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphQLEnum: GraphQLEnumType,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphQLEnum.name).swift").path

    let data = EnumTemplate(graphqlEnum: graphQLEnum).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
