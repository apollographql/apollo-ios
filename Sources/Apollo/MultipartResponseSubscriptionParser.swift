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
      }
    }
  }

  private enum DataLine {
    case heartbeat
    case contentHeader(type: String)
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

      if dataLine.starts(with: contentTypeHeader.description) {
        let contentType = (dataLine
          .components(separatedBy: ":").last ?? dataLine
        ).trimmingCharacters(in: .whitespaces)

        return .contentHeader(type: contentType)
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

  static func parse(_ chunk: String) -> Result<Data?, Error> {
    for dataLine in chunk.components(separatedBy: Self.dataLineSeparator.description) {
      switch DataLine(dataLine.trimmingCharacters(in: .newlines)) {
      case .heartbeat:
        // Periodically sent by the router - noop
        break

      case let .contentHeader(type):
        guard type == "application/json" else {
          return .failure(ParsingError.unsupportedContentType(type: type))
        }

      case let .json(object):
        if let errors = object.errors {
          let message = errors.first?["message"] as? String

          return .failure(ParsingError.irrecoverableError(message: message))
        }

        guard let payload = object.payload else {
          return .failure(ParsingError.cannotParsePayloadData)
        }

        if payload is NSNull {
          // `payload` can be null such as in the case of a transport error
          break
        }

        guard
          let payload = payload as? JSONObject,
          let data: Data = try? JSONSerializationFormat.serialize(value: payload)
        else {
          return .failure(ParsingError.cannotParsePayloadData)
        }

        return .success(data)

      case .unknown:
        return .failure(ParsingError.cannotParseChunkData)
      }
    }

    return .success(nil)
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
