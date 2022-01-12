import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
struct InterfaceFileGenerator: FileGenerator, Equatable {
  let interfaceType: GraphQLInterfaceType
  let path: String

  var data: Data {
    #warning("TODO: need correct data template")
    return "public class \(interfaceType.name) {}".data(using: .utf8)!
  }

  init(interfaceType: GraphQLInterfaceType, directoryPath: String) {
    self.interfaceType = interfaceType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(interfaceType.name).swift").path
  }
}
