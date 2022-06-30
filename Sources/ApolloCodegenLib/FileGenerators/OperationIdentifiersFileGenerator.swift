import Foundation
import ApolloUtils

/// File generator to create a JSON formatted file of operation identifiers.
struct OperationIdentifiersFileGenerator {
  /// File path of the generated target.
  let filePath: String

  private var template: OperationIdentifiersTemplate

  /// Designated initializer.
  ///
  /// Parameters:
  ///  - config: A configuration object specifying output behavior.
  init?(config: ApolloCodegen.ConfigurationContext) {
    guard let path = config.config.output.operationIdentifiersPath else {
      return nil
    }

    self.filePath = path
    self.template = OperationIdentifiersTemplate()
  }

  /// Appends the operation to the collection of identifiers to be written to `path`.
  mutating func collectOperationIdentifier(_ operation: IR.Operation) {
    template.collectOperationIdentifier(operation)
  }

  /// Generates a file containing the operation identifiers.
  ///
  /// Parameters:
  ///  - fileManager: `FileManager` object used to create the file. Defaults to
  ///  `FileManager.default`.
  func generate(fileManager: FileManager = .default) throws {
    let rendered: String = try template.render()

    try fileManager.apollo.createFile(
      atPath: filePath,
      data: rendered.data(using: .utf8),
      overwrite: true
    )
  }
}
