import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects).
struct InputObjectFileGenerator: FileGenerator, Equatable {
  /// The `GraphQLInputObjectType` object used to build the file content.
  let inputObjectType: GraphQLInputObjectType
  let path: String

  var data: Data? {
    #warning("TODO: need correct data template")
    return "public struct \(inputObjectType.name) {}".data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - inputObjectType: The `GraphQLInputObjectType` object used to build the file content.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(inputObjectType: GraphQLInputObjectType, directoryPath: String) {
    self.inputObjectType = inputObjectType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(inputObjectType.name).swift").path
  }
}
