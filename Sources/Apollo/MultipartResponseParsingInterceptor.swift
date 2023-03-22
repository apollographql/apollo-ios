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

  private let dataLineSeparator: String = "\r\n\r\n"
  private let contentTypeHeader: String = "content-type:"
  private let heartbeat: String = "{}"

  public func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : ApolloAPI.GraphQLOperation {

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
      chain.proceedAsync(request: request, response: response, completion: completion)
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
      if chunk.isEmpty { continue }

      for dataLine in chunk.components(separatedBy: dataLineSeparator) {
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
          continue

        case let .json(object):
          if let errors = object["errors"] as? [JSONObject] {
            let message = errors.first?["message"] as? String

            chain.handleErrorAsync(
              MultipartResponseParsingError.irrecoverableError(message: message),
              request: request,
              response: response,
              completion: completion
            )
          }

          if let done = object["done"] as? Bool, done {
            // Exit at this point because the router will close the connection; errors would have
            // been reported or the subscription is complete.
            return
          }

          guard
            let payload = object["payload"] as? JSONObject,
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
          chain.proceedAsync(request: request, response: response, completion: completion)

          continue

        case .unknown:
          chain.handleErrorAsync(
            MultipartResponseParsingError.cannotParseChunkData,
            request: request,
            response: response,
            completion: completion
          )
          continue
        }
      }
    }
  }

  /// Parses the data line of a multipart response chunk
  private func parse(dataLine: String) -> ChunkedDataLine {
    if dataLine == heartbeat {
      return .heartbeat
    }

    if dataLine.starts(with: contentTypeHeader) {
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
