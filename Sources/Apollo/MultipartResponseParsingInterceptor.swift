import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Parses multipart response data into chunks and forwards each on to the next interceptor.
public struct MultipartResponseParsingInterceptor: ApolloInterceptor {

  public enum MultipartResponseParsingError: Error, LocalizedError, Equatable {
    case noResponseToParse
    case cannotParseResponseData
    case unsupportedContentType(type: String)
    case cannotParseChunkData
    case irrecoverableError(message: String?)
    case cannotParsePayloadData

    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "There is no response to parse. Check the order of your interceptors."
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

  private static let dataLineSeparator: StaticString = "\r\n\r\n"
  private static let contentTypeHeader: StaticString = "content-type:"
  private static let heartbeat: StaticString = "{}"

  public var id: String = UUID().uuidString

  public init() { }

  public func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {

    guard let response else {
      chain.handleErrorAsync(
        MultipartResponseParsingError.noResponseToParse,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    if !response.httpResponse.isMultipart {
      chain.proceedAsync(
        request: request,
        response: response,
        interceptor: self,
        completion: completion
      )
      return
    }

    guard
      let boundaryString = response.httpResponse.multipartBoundary,
      let dataString = String(data: response.rawData, encoding: .utf8)
    else {
      chain.handleErrorAsync(
        MultipartResponseParsingError.cannotParseResponseData,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    for chunk in dataString.components(separatedBy: "--\(boundaryString)") {
      if chunk.isEmpty || chunk.isBoundaryPrefix { continue }

      for dataLine in chunk.components(separatedBy: Self.dataLineSeparator.description) {
        switch (parse(dataLine: dataLine.trimmingCharacters(in: .newlines))) {
        case .heartbeat:
          // Periodically sent by the router - noop
          continue

        case let .contentHeader(type):
          guard type == "application/json" else {
            chain.handleErrorAsync(
              MultipartResponseParsingError.unsupportedContentType(type: type),
              request: request,
              response: response,
              completion: completion
            )
            return
          }

        case let .json(object):
          if let errors = object["errors"] as? [JSONObject] {
            let message = errors.first?["message"] as? String

            chain.handleErrorAsync(
              MultipartResponseParsingError.irrecoverableError(message: message),
              request: request,
              response: response,
              completion: completion
            )

            // These are fatal-level transport errors, don't process anything else.
            return
          }

          guard let payload = object["payload"] else {
            chain.handleErrorAsync(
              MultipartResponseParsingError.cannotParsePayloadData,
              request: request,
              response: response,
              completion: completion
            )
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
            chain.handleErrorAsync(
              MultipartResponseParsingError.cannotParsePayloadData,
              request: request,
              response: response,
              completion: completion
            )
            return
          }

          let response = HTTPResponse<Operation>(
            response: response.httpResponse,
            rawData: data,
            parsedResponse: nil
          )
          chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
          )

        case .unknown:
          chain.handleErrorAsync(
            MultipartResponseParsingError.cannotParseChunkData,
            request: request,
            response: response,
            completion: completion
          )
        }
      }
    }
  }

  /// Parses the data line of a multipart response chunk
  private func parse(dataLine: String) -> ChunkedDataLine {
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
