import Foundation
import PackagePlugin

@main struct ApolloCodegenPluginGenerate: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    let process = Process()
    process.executableURL = try context.codegenExecutable
    process.arguments = ["generate"] + arguments

    try process.run()
    process.waitUntilExit()
  }
}
