import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
struct InterfaceFileGenerator: FileGenerator, Equatable {
  /// The `GraphQLInterfaceType` object used to build the file content.
  let interfaceType: GraphQLInterfaceType
  let path: String

  var data: Data? {
    InterfaceTemplate(graphqlInterface: interfaceType)
      .render()
      .data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - interfaceType: The `GraphQLInterfaceType` object used to build the file content.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(interfaceType: GraphQLInterfaceType, directoryPath: String) {
    self.interfaceType = interfaceType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(interfaceType.name).swift").path
  }
}
