import Foundation

/// Provides the format to output an operation manifest file used for APQ registration.
struct LegacyAPQOperationManifestTemplate: OperationManifestTemplate {

  struct OperationJSONValue: Codable {
    let name: String
    let source: String
  }

  func render(operations: [OperationManifestItem]) throws -> String {
    try template(operations).description
  }

  private func template(_ operations: [OperationManifestItem]) throws -> TemplateString {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    return TemplateString(
    """
    {
      \(try operations.map({ operation in
          let value = OperationJSONValue(name: operation.name, source: operation.source)
          return """
            "\(operation.identifier)" : \(json: try encoder.encode(value))
            """
        }), separator: ",\n")
    }
    """
    )
  }

}
