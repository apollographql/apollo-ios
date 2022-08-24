import Foundation
import PackagePlugin

#warning("TODO: If the generator fails because of a file permissions error, we should tell the user that they need to use either the `--disable-sandbox flag` or `--allow-writing-to-directory` flag.")

@main struct ApolloCodegenPluginFetch: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    let process = Process()
    process.executableURL = try context.codegenExecutable
    process.arguments = ["fetch-schema"] + arguments

    try process.run()
    process.waitUntilExit()
  }
}
