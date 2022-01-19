import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
struct UnionFileGenerator: FileGenerator, Equatable {
  /// The `GraphQLUnionType` object used to build the file content.
  let unionType: GraphQLUnionType
  let path: String

  var data: Data? {
    #warning("TODO: need correct data template")
    return "public enum \(unionType.name) {}".data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - unionType: The `GraphQLUnionType` object used to build the file content.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(unionType: GraphQLUnionType, directoryPath: String) {
    self.unionType = unionType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(unionType.name).swift").path
  }
}
