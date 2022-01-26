import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
struct UnionFileGenerator: FileGenerator, Equatable {
  /// The `GraphQLUnionType` object used to build the file content.
  let unionType: GraphQLUnionType
  /// The name of the generated Swift code module.
  let moduleName: String
  let path: String

  var data: Data? {
    UnionTemplate(moduleName: moduleName, graphqlUnion: unionType)
      .render()
      .data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - unionType: The `GraphQLUnionType` object used to build the file content.
  ///  - moduleName: The name of the generated Swift code module.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(unionType: GraphQLUnionType, moduleName: String, directoryPath: String) {
    self.unionType = unionType
    self.moduleName = moduleName

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(unionType.name).swift").path
  }
}
