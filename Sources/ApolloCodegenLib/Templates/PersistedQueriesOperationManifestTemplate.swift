import Foundation

/// Provides the format to output an operation manifest file used for persisted queries.
struct PersistedQueriesOperationManifestTemplate {

  func render(operations: [OperationManifestItem]) throws -> String {
    try template(operations).description
  }

  private func template(_ operations: [OperationManifestItem]) throws -> TemplateString {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    return TemplateString(
      """
      {
        "format": "apollo-persisted-queries",
        "version": 1,
        "operations": [
          \(forEachIn: operations, terminator: ",", { operation in
            return """
            {
              "id": "\(operation.identifier)",
              "body": "\(operation.source)",
              "name": "\(operation.name),
              "type": "\(operation.type.rawValue)
            }
            """
          })
        ]
      }
      """
    )
  }

}
