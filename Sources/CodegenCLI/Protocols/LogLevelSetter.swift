import ApolloCodegenLib

public protocol LogLevelSetter {
  static func SetLoggingLevel(verbose: Bool)
  static func SetLoggingLevel(_ level: CodegenLogger.LogLevel)
}

extension LogLevelSetter {
  public static func SetLoggingLevel(verbose: Bool) {
    SetLoggingLevel(verbose ? .debug : .warning)
  }

  public static func SetLoggingLevel(_ level: CodegenLogger.LogLevel) {
    CodegenLogger.level = level
  }
}

extension CodegenLogger: LogLevelSetter { }
