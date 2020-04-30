//
//  LegacyParsingInterceptor.swift
//  Apollo
//
//  Created by Ellen Shapiro on 4/29/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation

public class LegacyParsingInterceptor: ApolloInterceptor {
  public var isCancelled: Bool = false
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    guard !self.isCancelled else {
      return
    }
    
    guard let data = response.rawData else {
      completion(.failure(ParserError.nilData))
      return
    }
    
    do {
      let json = try JSONSerializationFormat.deserialize(data: data) as? JSONObject
      guard let body = json else {
        throw ParserError.couldNotParseToLegacyJSON
      }
      
      let response = GraphQLResponse(operation: request.operation, body: body)
      
      let result = try response.parseResult().await()
      
    } catch {
      completion(.failure(error))
    }
  }
}
