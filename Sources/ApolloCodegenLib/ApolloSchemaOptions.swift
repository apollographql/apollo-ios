//
//  ApolloSchemaOptions.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 10/3/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

public struct ApolloSchemaOptions {
  
  public let apiKey: String?
  public let endpointURL: URL
  public let header: String?
  public let outputURL: URL
  
  public init(apiKey: String? = nil,
              endpointURL: URL,
              header: String? = nil,
              outputURL: URL) {
    self.apiKey = apiKey
    self.header = header
    self.endpointURL = endpointURL
    self.outputURL = outputURL
  }
  
  var arguments: [String] {
    var arguments = [
      "client:download-schema",
      "--endpoint=\(self.endpointURL.path)"
    ]
    
    if let header = self.header {
      arguments.append("--header=\(header)")
    }
    
    if let key = self.apiKey {
      arguments.append("--key=\(key)")
    }
    
    arguments.append(outputURL.path)
    
    return arguments
  }
}
