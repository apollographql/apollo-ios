import Foundation
import PackagePlugin

@main
struct InstallCLIPluginCommand: CommandPlugin {

  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    let dependencies = context.package.dependencies
    try dependencies.forEach { dep in
      if dep.package.displayName == "Apollo" {
        let process = Process()
        let path = try context.tool(named: "sh").path
        process.executableURL = URL(fileURLWithPath: path.string)
        process.arguments = ["\(dep.package.directory)/scripts/download-cli.sh", context.package.directory.string]
        try process.run()
        process.waitUntilExit()
      }
    }
  }

  func createSymbolicLink(from: PackagePlugin.Path, to: PackagePlugin.Path) throws {
    let task = Process()
    task.standardInput = nil
    task.environment = ProcessInfo.processInfo.environment
    task.arguments = ["-c", "ln -f -s '\(from.string)' '\(to.string)'"]
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
    let apolloPath = "\(context.pluginWorkDirectory)/../../checkouts/apollo-ios"
      print("Apollo Path - \(apolloPath)")
    let process = Process()
    let path = try context.tool(named: "sh").path
    process.executableURL = URL(fileURLWithPath: path.string)
    process.arguments = ["\(apolloPath)/scripts/download-cli.sh", context.xcodeProject.directory.string]
    try process.run()
    process.waitUntilExit()
  }

}
#endif
