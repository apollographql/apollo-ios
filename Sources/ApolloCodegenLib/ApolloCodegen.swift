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
  public enum CodegenError: Error, LocalizedError {
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
  /// - Parameter folder: The folder to run the script from
  /// - Parameter binaryFolderURL: The folder where the Apollo binaries have been unzipped.
  /// - Parameter options: The options object to use to run the code generation.
  public static func run(from folder: URL,
                         binaryFolderURL: URL,
                         options: ApolloCodegenOptions) throws -> String {
    let scriptPath = "\(binaryFolderURL.path)/run"
    
    let command =
      // Change directories to get into the path to run the script
      "cd \(folder.path)" +
      // Add the binary folder URL to $PATH so the script can find pre-compiled `node`
      " && export PATH=$PATH:\(binaryFolderURL.path)" +
      // Log out the version for debugging purposes
      " && \(scriptPath) --version" +
      // Set the final command to log out the passed-in arguments for debugging purposes
      " && set -x" +
      // Actually run the script with the given options.
      " && \(scriptPath) \(options.arguments.joined(separator: " "))"
    
    return try Basher.run(command: command, from: folder)
  }
  
  /// Runs code generation from the given folder with default options and the
  /// following assumptions:
  ///   - Schema is assumed to be at [folder]/schema.json
  ///   - Output is assumed to be a single file to [folder]/API.swift
  ///
  /// - Parameter folder: The folder to run the script from
  /// - Parameter binaryFolderURL: The folder where the Apollo binaries have been unzipped.
  public static func run(from folder: URL,
                         binaryFolderURL: URL) throws -> String {
    guard FileManager.default.apollo_folderExists(at: folder) else {
      throw CodegenError.folderDoesNotExist(folder)
    }
    
    let json = folder.appendingPathComponent("schema.json")
    let outputFileURL = folder.appendingPathComponent("API.swift")
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: outputFileURL),
                                       urlToSchemaFile: json)
    
    return try self.run(from: folder,
                        binaryFolderURL: binaryFolderURL,
                        options: options)
  }
}
