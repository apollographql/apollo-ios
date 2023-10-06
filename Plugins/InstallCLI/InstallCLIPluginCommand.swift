import Foundation
import PackagePlugin

@main
struct InstallCLIPluginCommand: CommandPlugin {

  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    var apolloDirectoryPath: Path? = nil
    let dependencies = context.package.dependencies
    dependencies.forEach { dep in
      if dep.package.displayName == "Apollo" {
          apolloDirectoryPath = dep.package.directory
      }
    }

    guard let apolloPath = apolloDirectoryPath else {
      fatalError("No Apollo dependency directory path")
    }
      
    let process = Process()
    let tarPath = try context.tool(named: "tar").path
    process.executableURL = URL(fileURLWithPath: tarPath.string)
    process.arguments = ["-xvf", "\(apolloPath)/CLI/apollo-ios-cli.tar.gz"]
    try process.run()
    process.waitUntilExit()
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
    let process = Process()
    let tarPath = try context.tool(named: "tar").path
    process.executableURL = URL(fileURLWithPath: tarPath.string)
    process.arguments = ["-xvf", "\(apolloPath)/CLI/apollo-ios-cli.tar.gz"]
    try process.run()
    process.waitUntilExit()
  }

}
#endif
