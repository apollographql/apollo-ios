import Foundation
import ApolloUtils

/// Provides the format to output a file used for APQ registration.
struct OperationIdentifiersTemplate {
  /// Collection of operation identifiers to be serialized.
  let operationIdentifiers: [OperationIdentifier]

  var template: TemplateString {
    TemplateString(
    """
    {
      \(operationIdentifiers.map({ operation in
      """
      "\(operation.hash)": {
        "name": "\(operation.name)",
        "source": "\(operation.source.jsonEscaped())"
      }
      """}), separator: ",\n")
    }
    """
    )
  }

  func render() -> String {
    template.description
  }
}

fileprivate extension String {
  func jsonEscaped() -> String {
    return replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
  }
}
