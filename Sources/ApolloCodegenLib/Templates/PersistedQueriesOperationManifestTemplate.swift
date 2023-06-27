import Foundation

/// Provides the format to output an operation manifest file used for persisted queries.
struct PersistedQueriesOperationManifestTemplate: OperationManifestTemplate {

  let config: ApolloCodegen.ConfigurationContext
  let encoder = JSONEncoder()

  func render(operations: [OperationManifestItem]) throws -> String {
    try template(operations).description
  }

  private func template(_ operations: [OperationManifestItem]) throws -> TemplateString {
    return try TemplateString(
      """
      {
        "format": "apollo-persisted-queries",
        "version": 1,
        "operations": [
          \(forEachIn: operations, terminator: ",", { operation in
            return """
            {
              "id": "\(operation.identifier)",
              "body": \(try operationSource(for: operation)),
              "name": "\(operation.name)",
              "type": "\(operation.type.rawValue)"
            }
            """
          })
        ]
      }
      """
    )
  }

  private func operationSource(for operation: OperationManifestItem) throws -> String {
    switch config.options.queryStringLiteralFormat {
    case .multiline:
      return TemplateString("\(json: try encoder.encode(operation.source))").description
    case .singleLine:
      return "\"\(operation.source.convertedToSingleLine())\""
    }
  }

}
