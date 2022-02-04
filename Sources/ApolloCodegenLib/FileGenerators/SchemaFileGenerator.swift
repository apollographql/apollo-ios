import Foundation
import OrderedCollections

struct SchemaFileGenerator {
  /// Generates a file containing schema metadata used when converting data to `Object` types at runtime.
  ///
  /// - Parameters:
  ///   - schema: IR representation of the GraphQL schema
  ///   - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ schema: IR.Schema,
    directoryPath: String,
    fileManager: FileManager = FileManager.default
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("Schema.swift").path

    let data = SchemaTemplate(
      schema: schema
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
