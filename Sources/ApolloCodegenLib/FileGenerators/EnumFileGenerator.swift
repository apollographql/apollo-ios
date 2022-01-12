import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
struct EnumFileGenerator: FileGenerator, Equatable {
  let enumType: GraphQLEnumType
  let path: String

  var data: Data {
    return "public enum \(enumType.name) {}".data(using: .utf8)!
  }

  init(enumType: GraphQLEnumType, directoryPath: String) {
    self.enumType = enumType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(enumType.name).swift").path
  }
}
