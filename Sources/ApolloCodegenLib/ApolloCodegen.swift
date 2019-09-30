//
//  ApolloCodegen.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 9/24/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

public class ApolloCodegen {
  
  public enum CodegenError: Error, LocalizedError {
    case folderDoesNotExist(_ url: URL)
    
    var localizedDescription: String {
      switch self {
      case .folderDoesNotExist(let url):
        return "There is no folder at \(url)!"
      }
    }
  }
  
  public static func run(from folder: URL, binaryFolderURL: URL, output: ApolloCodegenOptions.OutputFormat) throws -> String {
    
    guard FileManager.default.apollo_folderExists(at: folder) else {
      throw CodegenError.folderDoesNotExist(folder)
    }
    

    
    let json = folder.appendingPathComponent("schema.json")
    
    let options = ApolloCodegenOptions(outputFormat: output,
                                       urlToSchemaJSONFile: json)
    
    let scriptPath = "\(binaryFolderURL.path)/run"
    
    let command = "cd \(folder.path)" +
      " && export PATH=$PATH:\(binaryFolderURL.path)" +
      " && set -x" +
      " && \(scriptPath) --version" +
      " && \(scriptPath) \(options.arguments.joined(separator: " "))"
    
    let result = try Basher.run(command: command, from: folder)
    
    print(result)
    return result
  }
}
