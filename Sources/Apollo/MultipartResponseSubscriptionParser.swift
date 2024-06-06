import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct MultipartResponseSubscriptionParser: MultipartResponseSpecificationParser {
  public enum ParsingError: Swift.Error, LocalizedError, Equatable {
    case cannotParseResponseData
    case unsupportedContentType(type: String)
    case cannotParseChunkData
    case irrecoverableError(message: String?)
    case cannotParsePayloadData

    public var errorDescription: String? {
      switch self {
      case .cannotParseResponseData:
        return "The response data could not be parsed."
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

  private enum ChunkedDataLine {
    case heartbeat
    case contentHeader(type: String)
    case json(object: JSONObject)
    case unknown
  }

  static let protocolSpec: String = "subscriptionSpec=1.0"

  private static let dataLineSeparator: StaticString = "\r\n\r\n"
  private static let contentTypeHeader: StaticString = "content-type:"
  private static let heartbeat: StaticString = "{}"

  static func parse(
    data: Data,
    boundary: String,
    dataHandler: ((Data) -> Void),
    errorHandler: ((any Error) -> Void)
  ) {
    guard let dataString = String(data: data, encoding: .utf8) else {
      errorHandler(ParsingError.cannotParseResponseData)
      return
    }

    for chunk in dataString.components(separatedBy: "--\(boundary)") {
      if chunk.isEmpty || chunk.isBoundaryPrefix { continue }

      for dataLine in chunk.components(separatedBy: Self.dataLineSeparator.description) {
        switch (parse(dataLine: dataLine.trimmingCharacters(in: .newlines))) {
        case .heartbeat:
          // Periodically sent by the router - noop
          continue

        case let .contentHeader(type):
          guard type == "application/json" else {
            errorHandler(ParsingError.unsupportedContentType(type: type))
            return
          }

        case let .json(object):
          if let errors = object["errors"] as? [JSONObject] {
            let message = errors.first?["message"] as? String

            errorHandler(ParsingError.irrecoverableError(message: message))
            return
          }

          guard let payload = object["payload"] else {
            errorHandler(ParsingError.cannotParsePayloadData)
            return
          }

          if payload is NSNull {
            // `payload` can be null such as in the case of a transport error
            continue
          }

          guard
            let payload = payload as? JSONObject,
            let data: Data = try? JSONSerializationFormat.serialize(value: payload)
          else {
            errorHandler(ParsingError.cannotParsePayloadData)
            return
          }

          dataHandler(data)

        case .unknown:
          errorHandler(ParsingError.cannotParseChunkData)
        }
      }
    }
  }

  /// Parses the data line of a multipart response chunk
  private static func parse(dataLine: String) -> ChunkedDataLine {
    if dataLine == Self.heartbeat.description {
      return .heartbeat
    }

    if dataLine.starts(with: Self.contentTypeHeader.description) {
      return .contentHeader(type: (dataLine.components(separatedBy: ":").last ?? dataLine)
        .trimmingCharacters(in: .whitespaces)
      )
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

fileprivate extension String {
  var isBoundaryPrefix: Bool { self == "--" }
}
