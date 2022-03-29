import Foundation
import ApolloCodegenLib
import ArgumentParser

// In a typical app, you'll only need to do this for one target, so you'd
// set these up directly within this file. Here, we're using more than one
// target, so we're using an arg parser to figure out which one to build,
// and an enum to hold related options.
struct Codegen: ParsableCommand {

  enum ArgumentError: Error, LocalizedError {
    case invalidTargetName(name: String)
    case invalidPackageType(name: String)

    var errorDescription: String? {
      switch self {
      case let .invalidTargetName(name):
        return "The target \"\(name)\" is invalid. Please try again."

      case let .invalidPackageType(name):
        return "The package type \"\(name)\" is invalid. Please try again."
      }
    }
  }

  @Option(
    name: [.customLong("target"), .customShort("t")],
    help: "The target to generate code for - Required."
  )
  var targetName: String

  @Option(
    name: [.customLong("package-type"), .customShort("p")],
    help: "The package manager for the generated module - Required."
  )
  var packageManager: String

  mutating func run() throws {
    guard let target = Target(name: targetName) else {
      throw ArgumentError.invalidTargetName(name: targetName)
    }

    guard let module = Module(module: packageManager) else {
      throw ArgumentError.invalidPackageType(name: packageManager)
    }

    // Grab the parent folder of this file on the filesystem
    let parentFolderOfScriptFile = FileFinder.findParentFolder()

    // Use that to calculate the source root
    let sourceRootURL = parentFolderOfScriptFile
      .apollo.parentFolderURL() // Sources
      .apollo.parentFolderURL() // SwiftScripts
      .apollo.parentFolderURL() // apollo-ios

    let targetURL = target.targetRootURL(fromSourceRoot: sourceRootURL)
    let inputConfig = target.inputConfig(fromSourceRoot: sourceRootURL)
    let outputConfig = module.outputConfig(toTargetRoot: targetURL, schemaName: target.moduleName)

    // This more necessary if you're using a sub-folder, but make sure
    // there's actually a place to write out what you're doing.
    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: targetURL.path)

    // Actually attempt to generate code.
    try ApolloCodegen.build(with: ApolloCodegenConfiguration(input: inputConfig, output: outputConfig))
  }
}

Codegen.main()
