import Foundation
import PackagePlugin

@main struct CodegenPluginInitialize: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    let process = Process()
    process.executableURL = try context.codegenExecutable
    process.arguments = ["init"] + arguments

    try process.run()
    process.waitUntilExit()
  }
}
