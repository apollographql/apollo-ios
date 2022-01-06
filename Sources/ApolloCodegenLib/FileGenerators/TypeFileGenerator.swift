import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Object type](https://spec.graphql.org/draft/#sec-Objects).
struct TypeFileGenerator: FileGenerator {
  typealias graphQLType = GraphQLObjectType

  let objectType: GraphQLObjectType
  let filePath: String

  private let fileManager: FileManager

  init(
    objectType: GraphQLObjectType,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) {
    self.objectType = objectType
    self.fileManager = fileManager

    self.filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(objectType.name).swift").path
  }

  func generateFile() throws {
    #warning("TODO: Build correct content with template string")
    let data = "public class \(objectType.name) {}".data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
