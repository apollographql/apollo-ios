import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct MultipartResponseSubscriptionParser: MultipartResponseSpecificationParser {
  public enum ParsingError: Swift.Error, LocalizedError, Equatable {
    case unsupportedContentType(type: String)
    case cannotParseChunkData
    case irrecoverableError(message: String?)
    case cannotParsePayloadData
    case cannotParseErrorData

    public var errorDescription: String? {
      switch self {

      case let .unsupportedContentType(type):
        return "Unsupported content type: application/json is required but got \(type)."
      case .cannotParseChunkData:
        return "The chunk data could not be parsed."
      case let .irrecoverableError(message):
        return "An irrecoverable error occured: \(message ?? "unknown")."
      case .cannotParsePayloadData:
        return "The payload data could not be parsed."
      case .cannotParseErrorData:
        return "The error data could not be parsed."
      }
    }
  }

  private enum DataLine {
    case heartbeat
    case contentHeader(directives: [String])
    case json(object: JSONObject)
    case unknown

    init(_ value: String) {
      self = Self.parse(value)
    }

    private static func parse(_ dataLine: String) -> DataLine {
      var contentTypeHeader: StaticString { "content-type:" }
      var heartbeat: StaticString { "{}" }

      if dataLine == heartbeat.description {
        return .heartbeat
      }

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

  static let protocolSpec: String = "subscriptionSpec=1.0"

  static func parse(_ chunk: String) -> Result<Data?, any Error> {
    for dataLine in chunk.components(separatedBy: Self.dataLineSeparator.description) {
      switch DataLine(dataLine.trimmingCharacters(in: .newlines)) {
      case .heartbeat:
        // Periodically sent by the router - noop
        break

      case let .contentHeader(directives):
        guard directives.contains("application/json") else {
          return .failure(ParsingError.unsupportedContentType(type: directives.joined(separator: ";")))
        }

      case let .json(object):
        if let errors = object.errors, !(errors is NSNull) {
          guard
            let errors = errors as? [JSONObject],
            let message = errors.first?["message"] as? String
          else {
            return .failure(ParsingError.cannotParseErrorData)
          }

          return .failure(ParsingError.irrecoverableError(message: message))
        }

        if let payload = object.payload, !(payload is NSNull) {
          guard
            let payload = payload as? JSONObject,
            let data: Data = try? JSONSerializationFormat.serialize(value: payload)
          else {
            return .failure(ParsingError.cannotParsePayloadData)
          }

          return .success(data)
        }

        // 'errors' is optional because valid payloads don't have transport errors.
        // `errors` can be null because it's taken to be the same as optional.
        // `payload` is optional because the heartbeat message does not contain a payload field.
        // `payload` can be null such as in the case of a transport error or future use (TBD).
        return .success(nil)

      case .unknown:
        return .failure(ParsingError.cannotParseChunkData)
      }
    }

    return .success(nil)
  }
}

fileprivate extension JSONObject {
  var errors: JSONValue? {
    self["errors"]
  }

  var payload: JSONValue? {
    self["payload"]
  }
}
