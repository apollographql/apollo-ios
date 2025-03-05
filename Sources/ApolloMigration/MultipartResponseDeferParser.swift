import Foundation
#if !COCOAPODS
import ApolloMigrationAPI
#endif

struct MultipartResponseDeferParser: MultipartResponseSpecificationParser {
  public enum ParsingError: Swift.Error, LocalizedError, Equatable {
    case unsupportedContentType(type: String)
    case cannotParseChunkData
    case cannotParsePayloadData

    public var errorDescription: String? {
      switch self {

      case let .unsupportedContentType(type):
        return "Unsupported content type: 'application/graphql-response+json' or 'application/json' are supported, received '\(type)'."
      case .cannotParseChunkData:
        return "The chunk data could not be parsed."
      case .cannotParsePayloadData:
        return "The payload data could not be parsed."
      }
    }
  }

  private enum DataLine {
    case contentHeader(directives: [String])
    case json(object: JSONObject)
    case unknown

    init(_ value: String) {
      self = Self.parse(value)
    }

    private static func parse(_ dataLine: String) -> DataLine {
      if let directives = dataLine.parseContentTypeDirectives() {
        return .contentHeader(directives: directives)
      }

      if
        let data = dataLine.data(using: .utf8),
        let jsonObject = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
      {
        return .json(object: jsonObject)
      }

      return .unknown
    }
  }

  static let protocolSpec: String = "deferSpec=20220824"

  static func parse(_ chunk: String) -> Result<Data?, any Error> {
    for dataLine in chunk.components(separatedBy: Self.dataLineSeparator.description) {
      switch DataLine(dataLine.trimmingCharacters(in: .newlines)) {
      case let .contentHeader(directives):
        guard directives.contains(where: { $0.isValidGraphQLContentType }) else {
          return .failure(ParsingError.unsupportedContentType(type: directives.joined(separator: ";")))
        }

      case let .json(object):
        guard object.isPartialResponse || object.isIncrementalResponse else {
          return .failure(ParsingError.cannotParsePayloadData)
        }

        guard let serialized: Data = try? JSONSerializationFormat.serialize(value: object) else {
          return .failure(ParsingError.cannotParsePayloadData)
        }

        return .success(serialized)

      case .unknown:
        return .failure(ParsingError.cannotParseChunkData)
      }
    }

    return .success(nil)
  }
}

fileprivate extension JSONObject {
  var isPartialResponse: Bool {
    self.keys.contains("data") && self.keys.contains("hasNext")
  }

  var isIncrementalResponse: Bool {
    self.keys.contains("incremental") && self.keys.contains("hasNext")
  }
}
