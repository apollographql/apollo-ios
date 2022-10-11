import Foundation
import PackagePlugin

@main struct ApolloCodegenPluginFetch: CodegenCommand {
  static var commandName: String = "fetch-schema"
}

extension ApolloCodegenPluginFetch: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    try performCommand(contextProvider: context, arguments: arguments)
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension ApolloCodegenPluginFetch: XcodeCommandPlugin {
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    try performCommand(contextProvider: context, arguments: arguments)
  }
}
#endif
