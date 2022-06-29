import Foundation
import ApolloUtils
import OrderedCollections

/// Representation of an operation that supports Automatic Persisted Queries
struct OperationIdentifier {
  let hash: String
  let name: String
  let source: String
}

/// File generator to create a JSON formatted file of operation identifiers.
struct OperationIdentifiersFileGenerator {
  /// File path of the generated target.
  let filePath: String

  /// `OperationIdentifier` objects to be written to `path`.
  private var operationIdentifiers: [OperationIdentifier] = []

  /// Designated initializer.
  ///
  /// Parameters:
  ///  - config: A configuration object specifying output behavior.
  init?(config: ApolloCodegen.ConfigurationContext) {
    guard let path = config.config.output.operationIdentifiersPath else {
      return nil
    }

    self.filePath = path
  }

  /// Appends the operation to the collection of identifiers to be written to `path`.
  mutating func collectOperationIdentifier(_ operation: IR.Operation) {
    operationIdentifiers.append(OperationIdentifier(
      hash: operation.operationIdentifier,
      name: operation.definition.name,
      source: operation.definition.source
    ))
  }

  /// Generates a file containing the operation identifiers.
  ///
  /// Parameters:
  ///  - fileManager: `FileManager` object used to create the file. Defaults to
  ///  `FileManager.default`.
  func generate(fileManager: FileManager = .default) throws {
    let template = OperationIdentifiersTemplate(operationIdentifiers: operationIdentifiers)
    let rendered: String = template.render()

    try fileManager.apollo.createFile(
      atPath: filePath,
      data: rendered.data(using: .utf8),
      overwrite: true
    )
  }
}
