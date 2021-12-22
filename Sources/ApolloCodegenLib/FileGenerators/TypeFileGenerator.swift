import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Object type](https://spec.graphql.org/draft/#sec-Objects).
struct TypeFileGenerator: FileGenerator {
  typealias graphQLType = GraphQLObjectType

  static func generate(
    for object: GraphQLObjectType,
    in rootPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filename = object.jsValue.toString()!
    let filePath = URL(fileURLWithPath: rootPath).appendingPathComponent("\(filename).swift").path

    #warning("TODO: Build correct content with template string")
    let data = "public class \(object.name) {}".data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}

