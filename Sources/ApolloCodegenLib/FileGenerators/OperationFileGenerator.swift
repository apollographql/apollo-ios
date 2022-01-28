import Foundation

/// Generates a file containing the Swift representation of a GraphQL Operation.
struct OperationFileGenerator: FileGenerator {
  /// The `IR.Operation` object used to build the file content.
  let operation: IR.Operation
  let schema: IR.Schema
  let path: String

  var data: Data? {
    SelectionSetTemplate(schema: schema)
      .render(for: operation)
      .data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - operation: The `IR.Operation` object used to build the file content.
  ///  - schema: The `IR.Schema` the operation is belongs to.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(operation: IR.Operation, schema: IR.Schema, directoryPath: String) {
    self.operation = operation
    self.schema = schema

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(operation.definition.name).swift").path
  }
}
