import Foundation
import ApolloUtils

/// Provides the format to output a file used for APQ registration.
struct OperationIdentifiersTemplate {
  /// Collection of operation identifiers to be serialized.
  let operationIdentifiers: OperationIdentifierList

  private func template() throws -> TemplateString {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    return TemplateString(
    """
    {
      \(try operationIdentifiers.map({ key, value in
      """
      "\(key)" : \(json: try encoder.encode(value))
      """}), separator: ",\n")
    }
    """
    )
  }

  func render() throws -> String {
    try template().description
  }
}

fileprivate extension String.StringInterpolation {
  mutating func appendInterpolation(json jsonData: Data) {
    appendInterpolation(String(decoding: jsonData, as: UTF8.self))
  }
}
