import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
struct EnumFileGenerator: FileGenerator, Equatable {
  /// The `GraphQLEnumType` object used to build the file content.
  let enumType: GraphQLEnumType
  let path: String

  var data: Data? {
    EnumTemplate(graphqlEnum: self.enumType)
      .render()
      .data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - enumType: The `GraphQLEnumType` object used to build the file content.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(enumType: GraphQLEnumType, directoryPath: String) {
    self.enumType = enumType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(enumType.name).swift").path
  }
}
