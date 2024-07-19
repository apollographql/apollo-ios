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
    case mismatchedCurrentResultType
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

      case .mismatchedCurrentResultType:
        return "Partial result type operation does not match incremental result type operation."

      case let .couldNotParseIncrementalJSON(json):
        return "Could not parse incremental values - got \(json)."
      }
    }
  }

  public var id: String = UUID().uuidString
  private let resultStorage = ResultStorage()

  private class ResultStorage {
    var currentResult: Any?
    var currentCacheRecords: RecordSet?
  }

  public init() { }

  public func interceptAsync<Operation: GraphQLOperation>(
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
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
      let parsedCacheRecords: RecordSet?

      if let currentResult = resultStorage.currentResult {
        guard var currentResult = currentResult as? GraphQLResult<Operation.Data> else {
          throw ParsingError.mismatchedCurrentResultType
        }

        guard let incrementalItems = body["incremental"] as? [JSONObject] else {
          throw ParsingError.couldNotParseIncrementalJSON(json: body)
        }

        var currentCacheRecords = resultStorage.currentCacheRecords ?? RecordSet()

        for item in incrementalItems {
          let incrementalResponse = try IncrementalGraphQLResponse<Operation>(
            operation: request.operation,
            body: item
          )
          let (incrementalResult, incrementalCacheRecords) = try incrementalResponse.parseIncrementalResult(
            withCachePolicy: request.cachePolicy
          )
          currentResult = try currentResult.merging(incrementalResult)

          if let incrementalCacheRecords {
            currentCacheRecords.merge(records: incrementalCacheRecords)
          }
        }

        parsedResult = currentResult
        parsedCacheRecords = currentCacheRecords

      } else {
        let graphQLResponse = GraphQLResponse(
          operation: request.operation,
          body: body
        )
        let (result, cacheRecords) = try graphQLResponse.parseResult(withCachePolicy: request.cachePolicy)

        parsedResult = result
        parsedCacheRecords = cacheRecords
      }

      createdResponse.parsedResponse = parsedResult
      createdResponse.cacheRecords = parsedCacheRecords

      resultStorage.currentResult = parsedResult
      resultStorage.currentCacheRecords = parsedCacheRecords

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

}
