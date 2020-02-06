import Foundation

/// Bash command runner
public struct Basher {
  
  public enum BashError: Error, LocalizedError {
    case errorDuringTask(errorString: String, code: Int32)
    case noOutput(code: Int32)
    
    public var errorDescription: String? {
      switch self {
      case .errorDuringTask(let errorString, let code):
        return "Task failed with code \(code). Output: \(errorString)"
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
    
    if #available(OSX 10.13, *) {
      if let url = url {
        task.currentDirectoryURL = url
      }
      try task.run()
    } else {
      if let path = url?.path {
        task.currentDirectoryPath = path
      }
      task.launch()
    }
    
    task.waitUntilExit()
    
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
