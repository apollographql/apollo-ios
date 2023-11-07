import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Parses multipart response data into chunks and forwards each on to the next interceptor.
public struct MultipartResponseParsingInterceptor: ApolloInterceptor {

  public enum ParsingError: Error, LocalizedError, Equatable {
    case noResponseToParse
    case cannotParseResponse
    case cannotParseResponseData

    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "There is no response to parse. Check the order of your interceptors."
      case .cannotParseResponse:
        return "The response data could not be parsed."
      case .cannotParseResponseData:
        return "The response data could not be parsed."
      }
    }
  }

  private static let responseParsers: [String: MultipartResponseSpecificationParser.Type] = [
    MultipartResponseSubscriptionParser.protocolSpec: MultipartResponseSubscriptionParser.self,
    MultipartResponseDeferParser.protocolSpec: MultipartResponseDeferParser.self,
  ]

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
        ParsingError.noResponseToParse,
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

    let multipartComponents = response.httpResponse.multipartHeaderComponents

    guard
      let boundary = multipartComponents.boundary,
      let `protocol` = multipartComponents.protocol,
      let parser = Self.responseParsers[`protocol`]
    else {
      chain.handleErrorAsync(
        ParsingError.cannotParseResponse,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    guard let dataString = String(data: response.rawData, encoding: .utf8) else {
      chain.handleErrorAsync(
        ParsingError.cannotParseResponseData,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    for chunk in dataString.components(separatedBy: "--\(boundary)") {
      if chunk.isEmpty || chunk.isBoundaryMarker { continue }

      switch parser.parse(chunk) {
      case let .success(data):
        // Some chunks can be successfully parsed but do not require to be passed on to the next
        // interceptor, such as an HTTP subscription heartbeat message.
        if let data {
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
        }

      case let .failure(parserError):
        chain.handleErrorAsync(
          parserError,
          request: request,
          response: response,
          completion: completion
        )
      }
    }
  }
}

/// A protocol that multipart response parsers must conform to in order to be added to the list of
/// available response specification parsers.
protocol MultipartResponseSpecificationParser {
  /// The specification string matching what is expected to be received in the `Content-Type` header
  /// in an HTTP response.
  static var protocolSpec: String { get }

  /// Called to process each chunk in a multipart response.
  ///
  /// The return value is a `Result` type that indicates whether the chunk was successfully parsed
  /// or not. It is possible to return `.success` with a `nil` data value. This should only happen
  /// when the chunk was successfully parsed but there is no action to take on the message, such as
  /// a heartbeat message. Successful results with a `nil` data value will not be returned to the
  /// user.
  static func parse(_ chunk: String) -> Result<Data?, Error>
}

extension MultipartResponseSpecificationParser {
  static var dataLineSeparator: StaticString { "\r\n\r\n" }
}

fileprivate extension String {
  var isBoundaryMarker: Bool { self == "--" }
}
