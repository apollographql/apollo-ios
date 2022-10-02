import Foundation
import CodegenCLI
import ApolloCodegenLib

extension LogLevelSetter {
  static var mock: LogLevelSetter.Type {
    MockLogLevelSetter.self
  }
}

struct MockLogLevelSetter: LogLevelSetter {
  static var levelHandler: ((CodegenLogger.LogLevel) -> Void)? = nil

  static func SetLoggingLevel(_ level: CodegenLogger.LogLevel) {
    guard let levelHandler = levelHandler else {
      fatalError("You must set levelHandler before calling \(#function)!")
    }

    levelHandler(level)
  }
}
