import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Parses multipart response data into chunks and forwards each on to the next interceptor.
public struct MultipartResponseParsingInterceptor: ApolloInterceptor {

  public enum ParsingError: Error, LocalizedError, Equatable {
    case noResponseToParse
    @available(*, deprecated, message: "Use the more specific `missingMultipartBoundary` and `invalidMultipartProtocol` errors instead.")
    case cannotParseResponse
    case cannotParseResponseData
    case missingMultipartBoundary
    case invalidMultipartProtocol

    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "There is no response to parse. Check the order of your interceptors."
      case .cannotParseResponse:
        return "The response data could not be parsed."
      case .cannotParseResponseData:
        return "The response data could not be parsed."
      case .missingMultipartBoundary:
        return "Missing multipart boundary in the response 'content-type' header."
      case .invalidMultipartProtocol:
        return "Missing, or unknown, multipart specification protocol in the response 'content-type' header."
      }
    }
  }

  private static let responseParsers: [String: any MultipartResponseSpecificationParser.Type] = [
    MultipartResponseSubscriptionParser.protocolSpec: MultipartResponseSubscriptionParser.self,
    MultipartResponseDeferParser.protocolSpec: MultipartResponseDeferParser.self,
  ]

  public var id: String = UUID().uuidString

  public init() { }

  public func interceptAsync<Operation>(
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping GraphQLResultHandler<Operation.Data>
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

    guard let boundary = multipartComponents.boundary else {
      chain.handleErrorAsync(
        ParsingError.missingMultipartBoundary,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    guard
      let `protocol` = multipartComponents.protocol,
      let parser = Self.responseParsers[`protocol`]
    else {
      chain.handleErrorAsync(
        ParsingError.invalidMultipartProtocol,
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

    // Parsing Notes:
    //
    // Multipart messages arriving here may consist of more than one chunk, but they are always
    // expected to be complete chunks. Downstream protocol specification parsers are only built
    // to handle the protocol specific message formats, i.e.: data between the multipart delimiter.
    let boundaryDelimiter = Self.boundaryDelimiter(with: boundary)
    for chunk in dataString.components(separatedBy: boundaryDelimiter) {
      if chunk.isEmpty || chunk.isDashBoundaryPrefix || chunk.isMultipartNewLine { continue }

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

// MARK: Specification Parser Protocol

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
  static func parse(_ chunk: String) -> Result<Data?, any Error>
}

extension MultipartResponseSpecificationParser {
  static var dataLineSeparator: StaticString { "\r\n\r\n" }
}

// MARK: Helpers

extension MultipartResponseParsingInterceptor {
  static func boundaryDelimiter(with boundary: String) -> String {
    "\r\n--\(boundary)"
  }

  static func closeBoundaryDelimiter(with boundary: String) -> String {
    boundaryDelimiter(with: boundary) + "--"
  }
}

extension String {
  fileprivate var isDashBoundaryPrefix: Bool { self == "--" }
  fileprivate var isMultipartNewLine: Bool { self == "\r\n" }

  /// Returns the range of a complete multipart chunk.
  func multipartRange(using boundary: String) -> String.Index? {
    // The end boundary marker indicates that no further chunks will follow so if this delimiter
    // if found then include the delimiter in the index. Search for this first.
    let closeBoundaryDelimiter = MultipartResponseParsingInterceptor.closeBoundaryDelimiter(with: boundary)
    if let endIndex = range(of: closeBoundaryDelimiter, options: .backwards)?.upperBound {
      return endIndex
    }

    // A chunk boundary indicates there may still be more chunks to follow so the index need not
    // include the chunk boundary in the index.
    let boundaryDelimiter = MultipartResponseParsingInterceptor.boundaryDelimiter(with: boundary)
    if let chunkIndex = range(of: boundaryDelimiter, options: .backwards)?.lowerBound {
      return chunkIndex
    }

    return nil
  }

  func parseContentTypeDirectives() -> [String]? {
    var lowercasedContentTypeHeader: StaticString { "content-type:" }

    guard lowercased().starts(with: lowercasedContentTypeHeader.description) else {
      return nil
    }

    return dropFirst(lowercasedContentTypeHeader.description.count)
      .components(separatedBy: ";")
      .map({ $0.trimmingCharacters(in: .whitespaces) })
  }

  var isValidGraphQLContentType: Bool {
    self == "application/json" || self == "application/graphql-response+json"
  }
}
