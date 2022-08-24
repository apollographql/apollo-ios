import Foundation
import PackagePlugin

@main struct CodegenPlugin: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    print("It's all linked up!")
  }
}
