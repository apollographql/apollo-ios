import Foundation
import OrderedCollections

/// Provides the format to output a file used for APQ registration.
struct LegacyAPQOperationManifestTemplate {

  struct OperationJSONValue: Codable {
    let name: String
    let source: String
  }

  private func template(_ operations: [OperationManifestItem]) throws -> TemplateString {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    return TemplateString(
    """
    {
      \(try operations.map({ operation in
        let value = OperationJSONValue(name: operation.name, source: operation.source)
        return String("""
        "\(operation.identifier)" : \(json: try encoder.encode(value))
        """)}), separator: ",\n")
    }
    """
    )
  }

  func render(operations: [OperationManifestItem]) throws -> String {
    try template(operations).description
  }
}

fileprivate extension String.StringInterpolation {
  mutating func appendInterpolation(json jsonData: Data) {
    appendInterpolation(String(decoding: jsonData, as: UTF8.self))
  }
}
