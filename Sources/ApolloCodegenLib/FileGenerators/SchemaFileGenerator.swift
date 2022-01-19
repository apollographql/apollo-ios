import Foundation
import OrderedCollections

/// Generates a file containing schema metadata used when converting data to `Object` types at runtime.
struct SchemaFileGenerator: FileGenerator {
  /// IR representation of the GraphQL schema
  let schema: IR.Schema
  let path: String

  var data: Data? {
    #warning("TODO: need correct data template")
    return "public enum Schema {}".data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  /// - schema: IR representation of the GraphQL schema.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(schema: IR.Schema, directoryPath: String) {
    self.schema = schema

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("Schema.swift").path
  }
}
