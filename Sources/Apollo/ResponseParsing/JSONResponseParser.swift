import Foundation
import ApolloAPI

public enum JSONResponseParsingError: Swift.Error, LocalizedError {
  case couldNotParseToJSON(data: Data)
  case missingMultipartBoundary
  case invalidMultipartProtocol

  public var errorDescription: String? {
    switch self {
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

    case .missingMultipartBoundary:
      return "Missing multi-part boundary in the response 'content-type' header."

    case .invalidMultipartProtocol:
      return "Missing, or unknown, multi-part specification protocol in the response 'content-type' header."
    }
  }
}

/// ``JSONResponseParser`` parses JSON format GraphQL responses from raw HTTP responses into ``ParsedResult``s. This
/// parser performs GraphQL execution over the response data using a ``GraphQLExecutor``.
///  
/// ## Parsing Multi-part Data
/// Some GraphQL responses will be sent as multi-part data using the `Content-Type:multipart/mixed` header.
/// This parser currently supports parsing multiple response chunks received incrementally for the following multi-part
/// protocol specifications:
///  - `subscriptionSpec=1.0`: GraphQL subscriptions over HTTP. See ``MultipartResponseSubscriptionParser``
///  - `deferSpec=20220824`: GraphQL operations using the `@defer` directive. See ``MultipartResponseDeferParser``
///  
/// For supported multi-part responses, ``JSONResponseParser/parse(dataChunk:mergingIncrementalItemsInto:)`` can be
/// called each time a new response chunk is received, passing the previously received ``ParsedResult`` to the
/// `mergingIncrementalItemsInto` parameter. This will parse the new incremental items from the multi-part chunk and
/// merge them into the existing result, returning a new merged ``ParsedResult``. See ``JSONResponseParsingInterceptor``
/// for an example implementation.
public struct JSONResponseParser: Sendable {

  let response: HTTPURLResponse
  let operationVariables: GraphQLOperation.Variables?
  let includeCacheRecords: Bool
  let multipartHeader: HTTPURLResponse.MultipartHeaderComponents

  public init(
    response: HTTPURLResponse,
    operationVariables: GraphQLOperation.Variables?,
    includeCacheRecords: Bool
  ) {
    self.response = response
    self.multipartHeader = response.multipartHeaderComponents
    self.operationVariables = operationVariables
    self.includeCacheRecords = includeCacheRecords
  }

  /// Parses GraphQL response data as JSON
  /// - Parameters:
  ///   - dataChunk: A `Data` object for the response data. For a multi-part response, this should be the data for a
  ///   single chunk of the GraphQL response.
  ///   - existingResult: [optional] Used for multi-part responses only. The previously received ``ParsedResult`` for
  ///   newly received incremental items of the `dataChunk` to be merged into.
  /// - Returns: The parsed response as a ``ParsedResult``
  public func parse<Operation: GraphQLOperation>(
    dataChunk: Data,
    mergingIncrementalItemsInto existingResult: ParsedResult<Operation>?
  ) async throws -> ParsedResult<Operation>? {
    switch response.isMultipart {
    case false:
      return try await parseSingleResponse(data: dataChunk)

    case true:
      guard multipartHeader.boundary != nil else {
        throw JSONResponseParsingError.missingMultipartBoundary
      }

      guard
        let `protocol` = multipartHeader.`protocol`,
        let parser = multipartParser(forProtocol: `protocol`)
      else {
        throw JSONResponseParsingError.invalidMultipartProtocol
      }

      guard let parsedChunk = try parser.parse(multipartChunk: dataChunk) else {
        return nil
      }

      try Task.checkCancellation()

      if let incrementalItems = parsedChunk["incremental"] as? [JSONObject] {
        guard let existingResult else {
          throw IncrementalResponseError.missingExistingData
        }

        return try await executeIncrementalResponses(
          merging: incrementalItems,
          into: existingResult
        )

      } else {
        // Parse initial chunk
        return try await parseSingleResponse(body: parsedChunk)
      }
    }
  }

  // MARK: - Single Response Parsing

  func parseSingleResponse<Operation: GraphQLOperation>(
    data: Data
  ) async throws -> ParsedResult<Operation> {
    guard
      let body = try? JSONSerializationFormat.deserialize(data: data) as JSONObject
    else {
      throw JSONResponseParsingError.couldNotParseToJSON(data: data)
    }

    return try await parseSingleResponse(body: body)
  }

  func parseSingleResponse<Operation: GraphQLOperation>(
    body: JSONObject
  ) async throws -> ParsedResult<Operation> {
    let executionHandler = SingleResponseExecutionHandler<Operation>(
      responseBody: body,
      operationVariables: operationVariables
    )
    return try await executionHandler.execute(includeCacheRecords: includeCacheRecords)
  }

  // MARK: - Multipart Response Parsing

  private func multipartParser(
    forProtocol protocol: String
  ) -> (any MultipartResponseSpecificationParser.Type)? {
    switch `protocol` {
    case MultipartResponseSubscriptionParser.protocolSpec:
      return MultipartResponseSubscriptionParser.self

    case MultipartResponseDeferParser.protocolSpec:
      return MultipartResponseDeferParser.self

    default: return nil
    }
  }

  private func executeIncrementalResponses<Operation: GraphQLOperation>(
    merging incrementalItems: [JSONObject],
    into existingResult: ParsedResult<Operation>
  ) async throws -> ParsedResult<Operation> {
    var currentResult = existingResult.result
    var currentCacheRecords = existingResult.cacheRecords

    for item in incrementalItems {
      let (incrementalResult, incrementalCacheRecords) = try await executeIncrementalItem(
        itemBody: item,
        for: Operation.self
      )
      try Task.checkCancellation()

      currentResult = try currentResult.merging(incrementalResult)

      if let incrementalCacheRecords {
        currentCacheRecords?.merge(records: incrementalCacheRecords)
      }
    }

    return ParsedResult(result: currentResult, cacheRecords: currentCacheRecords)
  }

  private func executeIncrementalItem<Operation: GraphQLOperation>(
    itemBody: JSONObject,
    for operationType: Operation.Type
  ) async throws -> (IncrementalGraphQLResult, RecordSet?) {
    let incrementalExecutionHandler = try IncrementalResponseExecutionHandler<Operation>(
      responseBody: itemBody,
      operationVariables: operationVariables
    )

    return try await incrementalExecutionHandler.execute(includeCacheRecords: includeCacheRecords)
  }

}
