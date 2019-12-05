//
//  URL+QueryDict.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 10/14/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

extension URL {
  
  /// Transforms the query items with values into an optional dictionary so it can be subscripted. 
  var queryItemDictionary: [String: String]? {
    return URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .reduce([String: String]()) { dict, queryItem in
        guard let value = queryItem.value else {
          return dict
        }
        
        var updatedDict = dict
        updatedDict[queryItem.name] = value
        return updatedDict
      }
  }
}
