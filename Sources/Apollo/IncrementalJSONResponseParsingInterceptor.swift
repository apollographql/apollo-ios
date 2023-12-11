import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor which parses JSON response data into a `GraphQLResult` and attaches it to the 
/// `HTTPResponse`.
public struct IncrementalJSONResponseParsingInterceptor: ApolloInterceptor {

  public enum ParsingError: Error, LocalizedError {
    case noResponseToParse
    case couldNotParseToJSON(data: Data)
    case mismatchedCurrentResultType(expected: String, got: String)
    case couldNotParseIncrementalJSON(json: JSONValue)

    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "The JSON response parsing interceptor was called before a response was received. Double-check the order of your interceptors."

      case .couldNotParseToJSON(let data):
        var errorStrings = [String]()
        errorStrings.append("Could not parse data to JSON format.")
        if let dataString = String(bytes: data, encoding: .utf8) {
          errorStrings.append("Data received as a String was:")
          errorStrings.append(dataString)
        } else {
          errorStrings.append("Data of count \(data.count) also could not be parsed into a String.")
        }

        return errorStrings.joined(separator: " ")

      case let .mismatchedCurrentResultType(expected, got):
        return "Could not cast current result - expected \(expected), got \(got)."

      case let .couldNotParseIncrementalJSON(json):
        return "Could not parse incremental values - got \(json)."
      }
    }
  }

  public var id: String = UUID().uuidString
  private let resultStorage = ResultStorage()

  private class ResultStorage {
    var currentResult: Any?
  }

  public init() { }

  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard let createdResponse = response else {
      chain.handleErrorAsync(
        ParsingError.noResponseToParse,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    do {
      guard
        let body = try? JSONSerializationFormat.deserialize(data: createdResponse.rawData) as? JSONObject
      else {
        throw ParsingError.couldNotParseToJSON(data: createdResponse.rawData)
      }

      let parsedResult: GraphQLResult<Operation.Data>

      if let currentResult = resultStorage.currentResult {
        guard var currentResult = currentResult as? GraphQLResult<Operation.Data> else {
          throw ParsingError.mismatchedCurrentResultType(
            expected: String(describing: Operation.Data.self),
            got: String(describing: currentResult.self)
          )
        }

        guard let incrementalItems = body["incremental"] as? [JSONObject] else {
          throw ParsingError.couldNotParseIncrementalJSON(json: body)
        }

        for item in incrementalItems {
          let incrementalResponse = try IncrementalGraphQLResponse<Operation>(
            operation: request.operation,
            body: item
          )
          let incrementalResult = try incrementalResponse.parseIncrementalResult()
          currentResult = currentResult.mergingIn(incrementalResult)
        }

        parsedResult = currentResult

      } else {
        let graphQLResponse = GraphQLResponse(
          operation: request.operation,
          body: body
        )
        createdResponse.legacyResponse = graphQLResponse

        let result = try parseResult(from: graphQLResponse, cachePolicy: request.cachePolicy)

        parsedResult = result
      }

      createdResponse.parsedResponse = parsedResult
      resultStorage.currentResult = parsedResult

      chain.proceedAsync(
        request: request,
        response: createdResponse,
        interceptor: self,
        completion: completion
      )

    } catch {
      chain.handleErrorAsync(
        error,
        request: request,
        response: createdResponse,
        completion: completion
      )
    }
  }  

  private func parseResult<Data>(
    from response: GraphQLResponse<Data>,
    cachePolicy: CachePolicy
  ) throws -> GraphQLResult<Data> {
    switch cachePolicy {
    case .fetchIgnoringCacheCompletely:
      // There is no cache, so we don't need to get any info on dependencies. Use fast parsing.
      return try response.parseResultFast()
    default:
      let (parsedResult, _) = try response.parseResult()
      return parsedResult
    }
  }

}
