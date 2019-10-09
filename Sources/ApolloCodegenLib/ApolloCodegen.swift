//
//  ApolloCodegen.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 9/24/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

/// A class to facilitate running code generation
public class ApolloCodegen {
  
  /// Errors which can happen with code generation
  public enum ApolloCodegenError: Error, LocalizedError {
    case folderDoesNotExist(_ url: URL)
    
    var localizedDescription: String {
      switch self {
      case .folderDoesNotExist(let url):
        return "Can't run codegen from \(url) - there is no folder there!"
      }
    }
  }
  
  /// Runs code generation from the given folder with the passed-in options
  ///
  /// - Parameter folder: The folder to run the script from. Should be the folder that at some depth, contains all `.graphql` files.
  /// - Parameter scriptFolderURL: The folder where the Apollo scripts have been checked out.
  /// - Parameter options: The options object to use to run the code generation.
  public static func run(from folder: URL,
                         scriptFolderURL: URL,
                         options: ApolloCodegenOptions) throws -> String {
    let cli = try ApolloCLI.createCLI(scriptsFolderURL: scriptFolderURL)
    return try cli.runApollo(with: options.arguments, from: folder)
  }
  
  /// Runs code generation from the given folder with default options and the
  /// following assumptions:
  ///   - Schema is assumed to be at [folder]/schema.json
  ///   - Output is assumed to be a single file to [folder]/API.swift
  ///
  /// - Parameter folder: The folder to run the script from. Should be the folder that at some depth, contains all `.graphql` files.
  /// - Parameter scriptFolderURL: The folder where the Apollo scripts have been checked out.
  public static func run(from folder: URL,
                         scriptFolderURL: URL) throws -> String {
    guard FileManager.default.apollo_folderExists(at: folder) else {
      throw ApolloCodegenError.folderDoesNotExist(folder)
    }
    
    let json = folder.appendingPathComponent("schema.json")
    let outputFileURL = folder.appendingPathComponent("API.swift")
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: outputFileURL),
                                       urlToSchemaFile: json)
    
    return try self.run(from: folder,
                        scriptFolderURL: scriptFolderURL,
                        options: options)
  }
}
