import Foundation
import PackagePlugin

extension PluginContext {
  var codegenExecutable: URL {
    get throws {
      let tool = try tool(named: "apollo-ios-cli")
      return URL(fileURLWithPath: tool.path.string)
    }
  }
}
