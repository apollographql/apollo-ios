import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Object type](https://spec.graphql.org/draft/#sec-Objects).
struct TypeFileGenerator: FileGenerator, Equatable {
  let objectType: GraphQLObjectType
  let path: String

  var data: Data {
    return "public class \(objectType.name) {}".data(using: .utf8)!
  }

  init(objectType: GraphQLObjectType, directoryPath: String) {
    self.objectType = objectType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(objectType.name).swift").path
  }
}
