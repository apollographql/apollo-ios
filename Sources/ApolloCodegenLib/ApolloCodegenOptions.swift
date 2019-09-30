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
  
  /// Enum to select how you want to export your API files.
  public enum OutputFormat {
    /// Outputs everything into a single file at the given URL.
    /// NOTE: URL must be a file URL
    case singleFile(atFileURL: URL)
    /// Outputs everything into individual files in a folder a the given URL
    /// NOTE: URL must be a folder URL
    case multipleFiles(inFolderAtURL: URL)
  }
  
  public let includes: String
  public let mergeInFieldsFromFragmentSpreads: Bool
  public let namespace: String?
  public let only: URL?
  public let operationIDsURL: URL?
  public let outputFormat: OutputFormat
  public let passthroughCustomScalars: Bool
  public let urlToSchemaFile: URL

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - includes: Glob of files to search for GraphQL operations. This should be used to find queries *and* any client schema extensions. Defaults to `./**/*.graphql`, which will search for `.graphql` files throughout all subfolders of the folder where the script is run.
  ///  - mergeInFieldsFromFragmentSpreads: Set true to merge fragment fields onto its enclosing type. Defaults to true.
  ///  - namespace: [optional] The namespace to emit generated code into. Defaults to nil.
  ///  - only: [optional] Parse all input files, but only output generated code for the file at this URL if non-nil. Defaults to nil.
  ///  - operationIDsURL: [optional] Path to an operation id JSON map file. If specified, also stores the operation ids (hashes) as properties on operation types. Defaults to nil.
  ///  - outputFormat: The `OutputFormat` enum option to use to output generated code.
  ///  - passthroughCustomScalars: Set true to use your own types for custom scalars. Defaults to false.
  ///  - urlToSchemaFile: The URL to your schema file.
  public init(includes: String = "./**/*.graphql",
              mergeInFieldsFromFragmentSpreads: Bool = true,
              namespace: String? = nil,
              only: URL? = nil,
              operationIDsURL: URL? = nil,
              outputFormat: OutputFormat,
              passthroughCustomScalars: Bool = false,
              urlToSchemaFile: URL) {
    self.includes = includes
    self.mergeInFieldsFromFragmentSpreads = mergeInFieldsFromFragmentSpreads
    self.namespace = namespace
    self.only = only
    self.operationIDsURL = operationIDsURL
    self.outputFormat = outputFormat
    self.passthroughCustomScalars = false
    self.urlToSchemaFile = urlToSchemaFile
  }
  
  var arguments: [String] {
    var arguments = [
      "codegen:generate",
      "--target=swift",
      "--addTypename",
      "--includes=\(self.includes)",
      "--localSchemaFile=\(self.urlToSchemaFile.path)"
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
    
    if self.mergeInFieldsFromFragmentSpreads {
      arguments.append("--mergeInFieldsFromFragmentSpreads")
    }
    
    switch self.outputFormat {
    case .singleFile(let fileURL):
      arguments.append(fileURL.path)
    case .multipleFiles(let folderURL):
      arguments.append(folderURL.path)
    }
    
    return arguments
  }
}
