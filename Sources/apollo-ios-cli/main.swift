import Foundation
import ArgumentParser
import CodegenCLI

struct Apollo_iOS_CLI: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "apollo-ios-cli",
    abstract: "A command line utility for Apollo iOS code generation.",
    version: "1.0.0-rc.1",
    subcommands: [
      CodegenCLI.Initialize.self,
      CodegenCLI.Generate.self,
      CodegenCLI.FetchSchema.self,
    ]
  )
}

Apollo_iOS_CLI.main()
