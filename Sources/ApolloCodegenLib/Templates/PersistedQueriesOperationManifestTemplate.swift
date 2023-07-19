import Foundation

/// Provides the format to output an operation manifest file used for persisted queries.
struct PersistedQueriesOperationManifestTemplate: OperationManifestTemplate {

  let config: ApolloCodegen.ConfigurationContext
  let encoder = JSONEncoder()

  func render(operations: [OperationManifestItem]) -> String {
    template(operations).description
  }

  private func template(_ operations: [OperationManifestItem]) -> TemplateString {
    return TemplateString(
      """
      {
        "format": "apollo-persisted-query-manifest",
        "version": 1,
        "operations": [
          \(forEachIn: operations, terminator: ",", { operation in
            return """
            {
              "id": "\(operation.identifier)",
              "body": "\(operation.source)",
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

}
