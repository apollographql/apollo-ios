//
//  GraphQLGETTransformer.swift
//  Apollo
//
//  Created by Ellen Shapiro on 7/1/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

struct GraphQLGETTransformer {
  
  let body: GraphQLMap
  let url: URL
  
  private let variablesKey = "variables"
  private let queryKey = "query"
  
  /// A helper for transforming a GraphQLMap that can be sent with a `POST` request into a URL with query parameters for a `GET` request.
  ///
  /// - Parameters:
  ///   - body: The GraphQLMap to transform from the body of a `POST` request
  ///   - url: The base url to append the query to.
  init(body: GraphQLMap,
       url: URL) {
    self.body = body
    self.url = url
  }
  
  /// Creates the get URL.
  ///
  /// - Returns: [optional] The created get URL or nil if the provided information couldn't be used to access the appropriate parameters.
  func createGetURL() -> URL? {
    guard var components = URLComponents(string: self.url.absoluteString) else {
      return nil
    }
    
    guard let query = self.body.jsonObject[self.queryKey] as? String else {
      return nil
    }
    
    var queryItems = components.queryItems ?? [URLQueryItem]()

    queryItems.append(URLQueryItem(name: self.queryKey, value: query))
    components.queryItems = queryItems
    
    guard let variables = self.body.jsonObject[self.variablesKey] as? [String: AnyHashable] else {
      return components.url
    }
    
    guard
      let serializedData = try? JSONSerialization.data(withJSONObject: variables),
      let jsonString = String(bytes: serializedData, encoding: .utf8) else {
        return components.url
    }
    
    queryItems.append(URLQueryItem(name: self.variablesKey, value: jsonString))
    components.queryItems = queryItems
    
    return components.url
  }
}

