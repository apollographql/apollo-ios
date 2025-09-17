import Foundation
import ApolloAPI

/// A `MultipartResponseSpecificationParser` that parses response data for GraphQL subscriptions over HTTP as defined by
/// the [`subscriptionSpec=1.0`](https://www.apollographql.com/docs/graphos/routing/operations/subscriptions/multipart-protocol)
/// specification.
public struct MultipartResponseSubscriptionParser: MultipartResponseSpecificationParser {
  public enum ParsingError: Swift.Error, LocalizedError, Equatable {
    case unsupportedContentType(type: String)
    case cannotParseChunkData
    case irrecoverableErrors([GraphQLError])
    case cannotParsePayloadData

    public var errorDescription: String? {
      switch self {

      case let .unsupportedContentType(type):
        return "Unsupported content type: application/json is required but got \(type)."
      case .cannotParseChunkData:
        return "The chunk data could not be parsed."
      case .irrecoverableErrors:
        return "An irrecoverable error occured."
      case .cannotParsePayloadData:
        return "The payload data could not be parsed."
      }
    }
  }

  private enum DataLine {
    case heartbeat
    case contentHeader(type: MultipartResponseParsing.ContentTypeDataLine)
    case json(object: JSONObject)
    case unknown

    init(_ value: Data) {
      self = Self.parse(value)
    }

    static let HeartbeatMessage: Data = Data([0x7b, 0x7d]) // "{}"

    private static func parse(_ dataLine: Data) -> DataLine {
      if dataLine == HeartbeatMessage {
        return .heartbeat
      }

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

  static let protocolSpec: String = "subscriptionSpec=1.0"

  static func parse(multipartChunk chunk: Data) throws -> JSONObject? {
    var dataLines = MultipartResponseParsing.DataLineIterator(data: chunk)
    while let dataLine = dataLines.next() {
      switch DataLine(dataLine) {
      case .heartbeat:
        // Periodically sent by the router - noop
        break

      case let .contentHeader(contentType):
        guard SupportedContentTypes.contains(contentType) else {
          throw ParsingError.unsupportedContentType(type: contentType.valueString)
        }

      case let .json(object):
        if let errorsJSON = object.errors {
          throw ParsingError.irrecoverableErrors(errorsJSON.map(GraphQLError.init))
        }

        if let payload = object.payload, !(payload is NSNull) {
          guard
            let payload = payload as? JSONObject
          else {
            throw ParsingError.cannotParsePayloadData
          }

          return payload
        }

        // 'errors' is optional because valid payloads don't have transport errors.
        // `errors` can be null because it's taken to be the same as optional.
        // `payload` is optional because the heartbeat message does not contain a payload field.
        // `payload` can be null such as in the case of a transport error or future use (TBD).
        return nil

      case .unknown:
        throw ParsingError.cannotParseChunkData
      }
    }

    return nil
  }
}

fileprivate extension JSONObject {
  var errors: [JSONObject]? {
    self["errors"] as? [JSONObject]
  }

  var payload: JSONValue? {
    self["payload"]
  }
}
