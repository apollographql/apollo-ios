import Foundation
import PackagePlugin

protocol PluginContextProvider {
  func tool(named name: String) throws -> PackagePlugin.PluginContext.Tool
}

extension PluginContextProvider {
  var codegenExecutable: URL {
    get throws {
      let executable = try tool(named: "apollo-ios-cli")
      return URL(fileURLWithPath: executable.path.string)
    }
  }
}

extension PluginContext: PluginContextProvider {}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodePluginContext: PluginContextProvider {}
#endif
