import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

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
      return "Missing multipart boundary in the response 'content-type' header."

    case .invalidMultipartProtocol:
      return "Missing, or unknown, multipart specification protocol in the response 'content-type' header."
    }
  }
}

public struct JSONResponseParser: Sendable {

  let response: HTTPURLResponse
  let operationVariables: GraphQLOperation.Variables?
  let multipartHeader: HTTPURLResponse.MultipartHeaderComponents
  let includeCacheRecords: Bool

  init(
    response: HTTPURLResponse,
    operationVariables: GraphQLOperation.Variables?,
    includeCacheRecords: Bool
  ) {
    self.response = response
    self.multipartHeader = response.multipartHeaderComponents
    self.operationVariables = operationVariables
    self.includeCacheRecords = includeCacheRecords
  }

  public func parse<Operation: GraphQLOperation>(
    dataChunk: Data,
    mergingIncrementalItemsInto existingResult: GraphQLResponse<Operation>?
  ) async throws -> GraphQLResponse<Operation>? {
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

  public func parseSingleResponse<Operation: GraphQLOperation>(
    data: Data
  ) async throws -> GraphQLResponse<Operation> {
    guard
      let body = try? JSONSerializationFormat.deserialize(data: data) as JSONObject
    else {
      throw JSONResponseParsingError.couldNotParseToJSON(data: data)
    }

    return try await parseSingleResponse(body: body)
  }

  public func parseSingleResponse<Operation: GraphQLOperation>(
    body: JSONObject
  ) async throws -> GraphQLResponse<Operation> {
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
    into existingResult: GraphQLResponse<Operation>
  ) async throws -> GraphQLResponse<Operation> {
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

    return GraphQLResponse(result: currentResult, cacheRecords: currentCacheRecords)
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
