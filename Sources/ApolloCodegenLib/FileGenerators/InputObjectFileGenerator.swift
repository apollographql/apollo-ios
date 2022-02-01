import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects).
struct InputObjectFileGenerator {
  /// Converts `graphQLInputObject` into Swift code and writes the result to a file in `directoryPath`.
  ///
  /// - Parameters:
  ///   - graphQLInputObject: The `GraphQLInputObjectType` object used to build the file content.
  ///   - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ graphQLInputObject: GraphQLInputObjectType,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(graphQLInputObject.name).swift").path

    let data = InputObjectTemplate(
      graphqlInputObject: graphQLInputObject
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
