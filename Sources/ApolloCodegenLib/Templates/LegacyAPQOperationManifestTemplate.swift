import Foundation

/// Provides the format to output an operation manifest file used for APQ registration.
struct LegacyAPQOperationManifestTemplate: OperationManifestTemplate {

  func render(operations: [OperationManifestItem]) -> String {
    template(operations).description
  }

  private func template(_ operations: [OperationManifestItem]) -> TemplateString {
    return TemplateString(
    """
    {
      \(operations.map({ operation in
          return """
            "\(operation.identifier)" : {
              "name": "\(operation.name)",
              "source": "\(operation.source)"
            }
            """
        }), separator: ",\n")
    }
    """
    )
  }

}
