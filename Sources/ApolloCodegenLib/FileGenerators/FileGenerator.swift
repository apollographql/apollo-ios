import Foundation
import ApolloUtils

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  associatedtype graphQLType

  static func generate(
    for object: graphQLType,
    in rootPath: String,
    fileManager: FileManager
  ) throws
}
