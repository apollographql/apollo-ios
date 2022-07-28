import Foundation

/// Helper to get logs printing to stdout so they can be read from the command line.
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
  
  /// The `LogLevel` at which to print logs. Higher raw values than this will
  /// be ignored. Defaults to `debug`.
  public static var level = LogLevel.debug
  
  /// Logs the given string if its `logLevel` is at or above `CodegenLogger.level`, otherwise ignores it.
  ///
  /// - Parameter logString: The string to log out, as an autoclosure
  /// - Parameter logLevel: The log level at which to print this specific log. Defaults to `debug`.
  /// - Parameter file: The file where this function was called. Defaults to the direct caller.
  /// - Parameter line: The line where this function was called. Defaults to the direct caller.
  public static func log(_ logString: @autoclosure () -> String,
                         logLevel: LogLevel = .debug,
                         file: StaticString = #file,
                         line: UInt = #line) {
    guard logLevel.rawValue <= CodegenLogger.level.rawValue else {
      // We're not logging anything at this level.
      return
    }
    
    var standardOutput = FileHandle.standardOutput
    print("[\(logLevel.name) - ApolloCodegenLib:\(file.lastPathComponent):\(line)] - \(logString())", to: &standardOutput)
  }
}

// Extension which allows `print` to output to a FileHandle
extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}
