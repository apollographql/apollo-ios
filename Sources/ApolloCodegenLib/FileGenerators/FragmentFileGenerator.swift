import Foundation

/// Generates a file containing the Swift representation of a GraphQL Fragment.
struct FragmentFileGenerator: FileGenerator {
  /// The `IR.NamedFragment` object used to build the file content.
  let fragment: IR.NamedFragment
  let schema: IR.Schema
  let config: ApolloCodegenConfiguration
  let path: String

  var data: Data? {
    FragmentTemplate(fragment: fragment, schema: schema, config: config)
      .render()
      .data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - fragment: The `IR.NamedFragment` object used to build the file content.
  ///  - schema: The `IR.Schema` the fragment is belongs to.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(
    fragment: IR.NamedFragment,
    schema: IR.Schema,
    config: ApolloCodegenConfiguration,
    directoryPath: String
  ) {
    self.fragment = fragment
    self.schema = schema
    self.config = config
    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("\(fragment.definition.name).swift").path
  }
}
