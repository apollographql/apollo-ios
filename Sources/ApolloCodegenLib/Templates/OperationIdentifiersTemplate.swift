import Foundation
import ApolloUtils
import OrderedCollections

/// Representation of an operation that supports Automatic Persisted Queries
struct OperationDetail: Codable {
  let name: String
  let source: String
}

/// Ordered dictionary of operation details keyed by the computed hash.
typealias OperationIdentifierList = OrderedDictionary<String, OperationDetail>

/// Provides the format to output a file used for APQ registration.
struct OperationIdentifiersTemplate {
  /// Collection of operation identifiers to be serialized.
  private var operationIdentifiers: OperationIdentifierList = [:]

  /// Appends the operation to the collection of identifiers to be serialized.
  mutating func collectOperationIdentifier(_ operation: IR.Operation) {
    var source = operation.definition.source
    for fragment in operation.referencedFragments {
      source += "\n\(fragment.definition.source)"
    }

    operationIdentifiers[operation.operationIdentifier] = OperationDetail(
      name: operation.definition.name,
      source: source
    )
  }

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
