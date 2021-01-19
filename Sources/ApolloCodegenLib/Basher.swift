import Foundation

// Only available on macOS
#if os(macOS)

/// Bash command runner
public struct Basher {
  
  public enum BashError: Error, LocalizedError {
    case errorDuringTask(code: Int32)
    case noOutput(code: Int32)
    
    public var errorDescription: String? {
      switch self {
      case .errorDuringTask(let code):
        return "Task failed with code \(code)."
      case .noOutput(let code):
        return "Task had no output. Exit code: \(code)."
      }
    }
  }
  
  /// Runs the given bash command as a string
  ///
  /// - Parameters:
  ///   - command: The bash command to run
  ///   - url: [optional] The URL to set as the `currentDirectoryURL`.
  /// - Returns: The result of the command.
  public static func run(command: String, from url: URL?) throws -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = [
      "-c",
      command
    ]
    task.launchPath = "/bin/bash"
    
    if let url = url {
      task.currentDirectoryURL = url
    }
    try task.run()
    
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    guard let output = String(bytes: data, encoding: .utf8) else {
      CodegenLogger.log("[No output from pipe]", logLevel: .error)
      throw BashError.noOutput(code: task.terminationStatus)
    }
    
    guard task.terminationStatus == 0 else {
      CodegenLogger.log(output, logLevel: .error)
      throw BashError.errorDuringTask(code: task.terminationStatus)
    }
    
    CodegenLogger.log(output)
    return output
  }
}

#endif
