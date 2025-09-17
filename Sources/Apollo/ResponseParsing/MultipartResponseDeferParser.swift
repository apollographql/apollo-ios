import Foundation
import ApolloAPI

/// A `MultipartResponseSpecificationParser` that parses response data for GraphQL operations that utilize the `@defer`
/// directive as defined by the [`deferSpec=20220824`](https://www.apollographql.com/docs/graphos/routing/operations/defer)
/// specification.
public struct MultipartResponseDeferParser: MultipartResponseSpecificationParser {
  public enum ParsingError: Swift.Error, LocalizedError, Equatable {
    case unsupportedContentType(type: String)
    case cannotParseChunkData
    case cannotParsePayloadData

    public var errorDescription: String? {
      switch self {

      case let .unsupportedContentType(type):
        return "Unsupported content type: application/json is required but got \(type)."
      case .cannotParseChunkData:
        return "The chunk data could not be parsed."
      case .cannotParsePayloadData:
        return "The payload data could not be parsed."
      }
    }
  }  

  private enum DataLine {
    case contentHeader(type: MultipartResponseParsing.ContentTypeDataLine)
    case json(object: JSONObject)
    case unknown

    init(_ value: Data) {
      self = Self.parse(value)
    }

    private static func parse(_ dataLine: Data) -> DataLine {
      if let contentType = MultipartResponseParsing.ContentTypeDataLine(dataLine) {
        return .contentHeader(type: contentType)
      }

      if let jsonObject = try? JSONSerializationFormat.deserialize(data: dataLine) as JSONObject {
        return .json(object: jsonObject)
      }

      return .unknown
    }
  }

  static let SupportedContentTypes: [MultipartResponseParsing.ContentTypeDataLine] = [
    .applicationJSON,
    .applicationGraphQLResponseJSON
  ]

  static let protocolSpec: String = "deferSpec=20220824"

  static func parse(multipartChunk chunk: Data) throws -> JSONObject? {
    var dataLines = MultipartResponseParsing.DataLineIterator(data: chunk)
    while let dataLine = dataLines.next() {
      switch DataLine(dataLine) {
      case let .contentHeader(contentType):
        guard SupportedContentTypes.contains(contentType) else {
          throw ParsingError.unsupportedContentType(type: contentType.valueString)
        }

      case let .json(object):
        guard object.isPartialResponse || object.isIncrementalResponse else {
          throw ParsingError.cannotParsePayloadData
        }
        return object

      case .unknown:
        throw ParsingError.cannotParseChunkData
      }
    }

    return nil
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
