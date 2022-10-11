import Foundation

protocol CodegenCommand {
  static var commandName: String { get }

  func performCommand(contextProvider: PluginContextProvider, arguments: [String]) throws
}

extension CodegenCommand {
  func performCommand(contextProvider: PluginContextProvider, arguments: [String]) throws {
    let process = Process()
    process.executableURL = try contextProvider.codegenExecutable
    process.arguments = [Self.commandName] + arguments

    try process.run()
    process.waitUntilExit()
  }
}
