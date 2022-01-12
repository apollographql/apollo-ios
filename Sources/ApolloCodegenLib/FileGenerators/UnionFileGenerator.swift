import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
struct UnionFileGenerator: FileGenerator, Equatable {
  let unionType: GraphQLUnionType
  let path: String

  var data: Data {
    #warning("TODO: need correct data template")
    return "public enum \(unionType.name) {}".data(using: .utf8)!
  }

  init(unionType: GraphQLUnionType, directoryPath: String) {
    self.unionType = unionType

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(unionType.name).swift").path
  }
}
