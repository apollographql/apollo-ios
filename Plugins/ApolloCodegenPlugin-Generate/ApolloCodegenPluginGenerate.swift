import Foundation
import PackagePlugin

@main struct ApolloCodegenPluginGenerate: CodegenCommand {
  static var commandName: String = "generate"
}

extension ApolloCodegenPluginGenerate: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    try performCommand(contextProvider: context, arguments: arguments)
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension ApolloCodegenPluginGenerate: XcodeCommandPlugin {
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    try performCommand(contextProvider: context, arguments: arguments)
  }
}
#endif
