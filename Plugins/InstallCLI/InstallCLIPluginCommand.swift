import Foundation
import PackagePlugin

@main
struct InstallCLIPluginCommand: CommandPlugin {

  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    let pathToCLI = try context.tool(named: "apollo-ios-cli").path
    try createSymbolicLink(from: pathToCLI, to: context.package.directory)
  }

  func createSymbolicLink(from: PackagePlugin.Path, to: PackagePlugin.Path) throws {
    let task = Process()
    task.standardInput = nil
    task.environment = ProcessInfo.processInfo.environment
    task.arguments = ["-c", "ln -f -s \(from.string) \(to.string)"]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    try task.run()
    task.waitUntilExit()
  }

}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension InstallCLIPluginCommand: XcodeCommandPlugin {

  /// 👇 This entry point is called when operating on an Xcode project.
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    print("Installing Apollo CLI Plugin to Xcode project \(context.xcodeProject.displayName)")
    let pathToCLI = try context.tool(named: "apollo-ios-cli").path
    try createSymbolicLink(from: pathToCLI, to: context.xcodeProject.directory)
  }

}
#endif
