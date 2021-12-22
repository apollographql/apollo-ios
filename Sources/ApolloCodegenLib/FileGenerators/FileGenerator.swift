import Foundation
import ApolloUtils

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  associatedtype graphQLType

  static func generateFile(
    for object: graphQLType,
    directoryPath: String,
    fileManager: FileManager
  ) throws
}
