import Foundation
import ApolloUtils

// MARK: FileGenerator (protocol and extension)

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  var fileName: String { get }
  var template: TemplateRenderer { get }
  var target: FileTarget { get }
}

extension FileGenerator {
  /// Generates the file writing the template content to the specified config output paths.
  ///
  /// - Parameters:
  ///   - config: Shared codegen configuration.
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  func generate(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>,
    fileManager: FileManager = FileManager.default
  ) throws {
    let directoryPath = target.resolvePath(forConfig: config)
    let filePath = URL(fileURLWithPath: directoryPath).appendingPathComponent(fileName).path

    let rendered: String = template.render(forConfig: config)

    try fileManager.apollo.createFile(atPath: filePath, data: rendered.data(using: .utf8))
  }
}
