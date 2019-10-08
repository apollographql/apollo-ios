//
//  CodegenLogger.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 10/3/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

public struct CodegenLogger {
  public enum LogLevel: Int {
    case error
    case warning
    case debug
    
    var name: String {
      switch self {
      case .error:
        return "ERROR"
      case .warning:
        return "WARNING"
      case .debug:
        return "DEBUG"
      }
    }
  }
  
  public static var level = LogLevel.debug
  
  public static func log(_ logString: @autoclosure () -> String,
                         logLevel: LogLevel = .debug,
                         file: StaticString = #file,
                         line: UInt = #line) {
    guard logLevel.rawValue <= CodegenLogger.level.rawValue else {
      // We're not logging anything at this level.
      return
    }
    
    var standardOutput = FileHandle.standardOutput
    print("[\(logLevel.name) - ApolloCodegenLib:\(file.apollo_lastPathComponent):\(line)] - \(logString())", to: &standardOutput)
  }
}

// Extension which allows `print` to ouput to a FileHandle
extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}
