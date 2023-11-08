import Foundation
import PackagePlugin

@main
struct InstallCLIPluginCommand: CommandPlugin {

  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    var apolloVersion: String? = nil
    let dependencies = context.package.dependencies
    try dependencies.forEach { dep in
      if dep.package.displayName == "Apollo" {
//          debugPrint("Apollo package directory - \(dep.package.directory)")
//          debugPrint("Apollo package id - \(dep.package.id)")
//          debugPrint("Apollo package origin - \(dep.package.origin)")
//          debugPrint("Apollo package toolsVersion - \(dep.package.toolsVersion)")
          let process = Process()
          let path = try context.tool(named: "sh").path
          process.executableURL = URL(fileURLWithPath: path.string)
          process.arguments = ["\(dep.package.directory)/scripts/get-version.sh"]
          let outputPipe = Pipe()
          process.standardOutput = outputPipe
          try process.run()
          process.waitUntilExit()
          
          let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
          if let version = String(data: data, encoding: .utf8) {
              apolloVersion = version.trimmingCharacters(in: .whitespacesAndNewlines)
          }
      }
    }
    
    debugPrint("Apollo Version - \(apolloVersion)")
      
//    guard let apolloPath = apolloDirectoryPath else {
//      fatalError("No Apollo dependency directory path")
//    }
      
//    let process = Process()
//    let tarPath = try context.tool(named: "tar").path
//    process.executableURL = URL(fileURLWithPath: tarPath.string)
//    process.arguments = ["-xvf", "\(apolloPath)/CLI/apollo-ios-cli.tar.gz"]
//    try process.run()
//    process.waitUntilExit()
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
