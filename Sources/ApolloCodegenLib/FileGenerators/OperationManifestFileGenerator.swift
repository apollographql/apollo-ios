import Foundation

/// Representation of an operation that supports Automatic Persisted Queries
struct OperationManifestItem {
  let name: String
  let identifier: String
  let source: String
  let type: CompilationResult.OperationType

  init(operation: IR.Operation) {
    self.name = operation.definition.name
    self.identifier = operation.operationIdentifier
    self.type = operation.definition.operationType

    var source = operation.definition.source
    for fragment in operation.referencedFragments {
      source += "\n\(fragment.definition.source)"
    }
    self.source = source
  }
}

/// File generator to create an operation manifest file.
struct OperationManifestFileGenerator {
  /// The `OperationManifestFileOutput` used to generated the operation manifest file.
  let config: ApolloCodegenConfiguration.OperationManifestFileOutput

  /// Collection of operation identifiers to be serialized.
  private var operationManifest: [OperationManifestItem] = []

  /// Designated initializer.
  ///
  /// Parameters:
  ///  - config: A configuration object specifying output behavior.
  init?(config: ApolloCodegen.ConfigurationContext) {
    guard let config = config.config.output.operationManifest else {
      return nil
    }

    self.config = config
  }

  /// Appends the operation to the collection of identifiers to be written to be serialized.
  mutating func collectOperationIdentifier(_ operation: IR.Operation) {
    operationManifest.append(OperationManifestItem(operation: operation))
  }

  /// Generates a file containing the operation identifiers.
  ///
  /// Parameters:
  ///  - fileManager: `ApolloFileManager` object used to create the file. Defaults to
  ///  `ApolloFileManager.default`.
  func generate(fileManager: ApolloFileManager = .default) throws {
    let template = LegacyAPQOperationManifestTemplate()
    let rendered: String = try template.render(operations: operationManifest)

    try fileManager.createFile(
      atPath: config.path,
      data: rendered.data(using: .utf8),
      overwrite: true
    )
  }
}
