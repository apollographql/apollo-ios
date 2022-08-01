import Foundation
import ArgumentParser

struct CodegenCLI: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "apollo-ios-cli",
    abstract: "A command line utility for Apollo iOS code generation.",
    version: "1.0.0-beta.1",
    subcommands: [
      Initialize.self,
      Generate.self,
      FetchSchema.self,
    ]
  )
}

CodegenCLI.main()
