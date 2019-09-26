//
//  Basher.swift
//  Apollo
//
//  Created by Ellen Shapiro on 9/25/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

public struct Basher {
  
  public enum BashError: Error, LocalizedError {
    case errorDuringTask(errorString: String, code: Int32)
    case noOutput(code: Int32)

    public var localizedDescription: String {
      switch self {
        case .errorDuringTask(let errorString, let code):
          return "Task failed with code \(code): \(errorString)"
        case .noOutput(let code):
          return "Task had no output. Exit code: \(code)."
      }
    }
  }
  
  public static func run(command: String) throws -> String {
      let task = Process()
      let pipe = Pipe()
      task.standardOutput = pipe
      task.standardError = pipe
      task.arguments = [
        "-c",
        command        
      ]
      task.launchPath = "/bin/bash"

      if #available(OSXApplicationExtension 10.13, *) {
        try task.run()
      } else {
        task.launch()
      }
      
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
      guard let output = String(bytes: data, encoding: .utf8) else {
        throw BashError.noOutput(code: task.terminationStatus)
      }
      
      
      guard task.terminationStatus == 0 else {
        throw BashError.errorDuringTask(errorString: output, code: task.terminationStatus)
      }
      
      return output
  }
}
