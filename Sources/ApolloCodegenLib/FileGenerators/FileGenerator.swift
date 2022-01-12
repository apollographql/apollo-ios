import Foundation
import ApolloUtils

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  var path: String { get }
  var data: Data { get }

  func generateFile(fileManager: FileManager) throws
}

extension FileGenerator {
  func generateFile(fileManager: FileManager = FileManager.default) throws {
    try fileManager.apollo.createFile(atPath: path, data: data)
  }
}
