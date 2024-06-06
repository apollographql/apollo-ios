import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Parses multipart response data into chunks and forwards each on to the next interceptor.
public struct MultipartResponseParsingInterceptor: ApolloInterceptor {

  public enum ParsingError: Error, LocalizedError, Equatable {
    case noResponseToParse
    case cannotParseResponse

    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "There is no response to parse. Check the order of your interceptors."
      case .cannotParseResponse:
        return "The response data could not be parsed."
      }
    }
  }

  private static let responseParsers: [String: any MultipartResponseSpecificationParser.Type] = [
    MultipartResponseSubscriptionParser.protocolSpec: MultipartResponseSubscriptionParser.self
  ]

  public var id: String = UUID().uuidString

  public init() { }

  public func interceptAsync<Operation>(
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
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

    let dataHandler: ((Data) -> Void) = { data in
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

    let errorHandler: ((any Error) -> Void) = { parserError in
      chain.handleErrorAsync(
        parserError,
        request: request,
        response: response,
        completion: completion
      )
    }

    parser.parse(
      data: response.rawData,
      boundary: boundary,
      dataHandler: dataHandler,
      errorHandler: errorHandler
    )
  }
}

/// A protocol that multipart response parsers must conform to in order to be added to the list of
/// available response specification parsers.
protocol MultipartResponseSpecificationParser {
  /// The specification string matching what is expected to be received in the `Content-Type` header
  /// in an HTTP response.
  static var protocolSpec: String { get }

  /// Function that will be called to process the response data.
  static func parse(
    data: Data,
    boundary: String,
    dataHandler: ((Data) -> Void),
    errorHandler: ((any Error) -> Void)
  )
}
