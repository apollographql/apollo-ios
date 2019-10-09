//
//  ApolloSchemaOptions.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 10/3/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

/// Options for running the Apollo Schema Downloader.
public struct ApolloSchemaOptions {
  
  public let apiKey: String?
  public let endpointURL: URL
  public let header: String?
  public let outputURL: URL
  
  /// Designated Initializer
  ///
  /// - Parameter apiKey: [optional] The API key to use when retrieving your schema. Defaults to nil.
  /// - Parameter endpointURL: The endpoint to hit to download your schema.
  /// - Parameter header: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
  /// - Parameter outputURL: The file URL where the downloaded schema should be written
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
