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
  }
  
  public static var level = LogLevel.debug
  
  public static func log(_ logString: @autoclosure () -> String,
                         logLevel: LogLevel = .debug,
                         file: StaticString = #file,
                         line: UInt = #line) {
    guard logLevel.rawValue <= CodegenLogger.level.rawValue else {
      // We're not logging anything at this level.
      print("NO LOG")
      return
    }
    
    var standardOutput = FileHandle.standardOutput
    print("[\(file.apollo_lastPathComponent):\(line)] - \(logString())", to: &standardOutput)
  }
}

extension FileHandle : TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}
