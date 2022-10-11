import Foundation
import PackagePlugin

@main struct ApolloCodegenPluginInitialize: CodegenCommand {
  static var commandName: String = "init"
}

extension ApolloCodegenPluginInitialize: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    try performCommand(contextProvider: context, arguments: arguments)
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension ApolloCodegenPluginInitialize: XcodeCommandPlugin {
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    try performCommand(contextProvider: context, arguments: arguments)
  }
}
#endif
