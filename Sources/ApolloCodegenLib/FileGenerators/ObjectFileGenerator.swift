import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
struct ObjectFileGenerator {
  /// Converts `graphQLObject` into Swift code and writes teh result to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLObject: The `GraphQLObjectType` object used to build the file content.
  ///   - directoryPath: The output path that the file will be written to.
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphQLObject: GraphQLObjectType,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphQLObject.name).swift").path

    let data = ObjectTemplate(
      graphqlObject: graphQLObject
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
