import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects).
struct InputObjectFileGenerator: FileGenerator, Equatable {
  let inputObjectType: GraphQLInputObjectType
  let path: String

  var data: Data {
    #warning("TODO: need correct data template")
    return "public struct \(inputObjectType.name) {}".data(using: .utf8)!
  }

  init(inputObjectType: GraphQLInputObjectType, directoryPath: String) {
    self.inputObjectType = inputObjectType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(inputObjectType.name).swift").path
  }
}
