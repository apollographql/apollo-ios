import Foundation
import ApolloUtils

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  /// The output path that the file will be written to.
  var path: String { get }
  /// The file content in UTF-8 encoding.
  var data: Data { get }

  /// Writes `data` to a file at the designated `path`. If the file already exists it will be overwritten.
  func generateFile(fileManager: FileManager) throws
}

extension FileGenerator {
  func generateFile(fileManager: FileManager = FileManager.default) throws {
    try fileManager.apollo.createFile(atPath: path, data: data)
  }
}
