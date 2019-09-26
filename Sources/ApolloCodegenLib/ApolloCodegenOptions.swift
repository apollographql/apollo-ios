//
//  ApolloCodegenOptions.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 9/24/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

/// An object to hold all the various options for running codegen
public struct ApolloCodegenOptions {
  
  public enum OutputFormat {
    case singleFile(atFileURL: URL)
    case multipleFiles(inFolderAtURL: URL)
  }
  
  public let urlToSchemaJSONFile: URL
  public let outputFormat: OutputFormat
  public let includes: String
  public let only: URL?
  public let addTypename: Bool
  public let mergeInFieldsFromFragmentSpreads: Bool
  public let namespace: String?
  public let operationIDsURL: URL?
  public let passthroughCustomScalars: Bool
  
  public init(addTypename: Bool = true,
              includes: String = "./**/*.graphql",
              mergeInFieldsFromFragmentSpreads: Bool = false,
              namespace: String? = nil,
              only: URL? = nil,
              operationIDsURL: URL? = nil,
              outputFormat: OutputFormat,
              passthroughCustomScalars: Bool = false,
              urlToSchemaJSONFile: URL) {
    self.urlToSchemaJSONFile = urlToSchemaJSONFile
    self.outputFormat = outputFormat
    self.addTypename = addTypename
    self.mergeInFieldsFromFragmentSpreads = mergeInFieldsFromFragmentSpreads
    self.namespace = namespace
    self.operationIDsURL = operationIDsURL
    self.passthroughCustomScalars = false
    self.includes = includes
    self.only = only
  }
  
  var arguments: [String] {
    var arguments = [
//      "-c",
//      "/Users/ellen/Desktop/Work/Apollo/apollo-ios/scripts/apollo/bin/run",
      "codegen:generate",
      "--target=swift",
    ]
    
    if let namespace = self.namespace {
      arguments.append("--namespace=\(namespace)")
    }
    
    if let only = only {
      arguments.append("--only=\(only.path)")
    }
    
    if let idsURL = self.operationIDsURL {
      arguments.append("--operationIdsPath=\(idsURL.path)")
    }
    
    if self.passthroughCustomScalars {
      arguments.append("--passthroughCustomScalars")
    }
    
    return arguments
  }
}
