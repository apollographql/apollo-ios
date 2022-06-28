import Foundation
import ApolloCodegenLib
import ArgumentParser
import TargetConfig

// In a typical app, you'll only need to do this for one target, so you'd
// set these up directly within this file. Here, we're using more than one
// target, so we're using an arg parser to figure out which one to build,
// and an enum to hold related options.
struct Codegen: ParsableCommand {
  @Option(
    wrappedValue: [],
    name: [.customLong("target"), .customShort("t")],
    parsing: .upToNextOption,
    help: "The target to generate code for."
  )
  var targetNames: [String]

  @Option(
    name: [.customLong("package-type"), .customShort("p")],
    help: "The package manager for the generated module - Required."
  )
  var packageManager: String

  mutating func run() throws {
    let targets = targetNames.isEmpty ?
    Target.allCases :
    try targetNames.map { try Target(name: $0) }

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

    for target in targets {
      let targetURL = target.targetRootURL(fromSourceRoot: sourceRootURL)
      let inputConfig = target.inputConfig(fromSourceRoot: sourceRootURL)
      let outputConfig = try target.outputConfig(
        fromSourceRoot: sourceRootURL,
        forModuleType: module.moduleType
      )

      // This more necessary if you're using a sub-folder, but make sure
      // there's actually a place to write out what you're doing.
      try FileManager.default.apollo.createDirectoryIfNeeded(atPath: targetURL.path)

      // Actually attempt to generate code.
      try ApolloCodegen.build(
        with: ApolloCodegenConfiguration(
          schemaName: target.moduleName,
          input: inputConfig,
          output: outputConfig,
          options: target.options(),
          experimentalFeatures: target.experimentalFeatures()
        )
      )
    }
  }
}

Codegen.main()
