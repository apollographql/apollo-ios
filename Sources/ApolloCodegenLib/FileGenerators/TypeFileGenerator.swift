import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Object type](https://spec.graphql.org/draft/#sec-Objects).
struct TypeFileGenerator: FileGenerator {
  typealias graphQLType = GraphQLObjectType

  static func generateFile(
    for object: GraphQLObjectType,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(object.name).swift").path

    #warning("TODO: Build correct content with template string")
    let data = "public class \(object.name) {}".data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}

