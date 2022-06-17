import Foundation
import ArgumentParser

struct CodegenCLI: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "apollo-ios-cli",
    abstract: "A command line utility for Apollo iOS code generation.",
    version: "1.0.0-alpha.8",
    subcommands: [
      Initialize.self,
      Validate.self,
      Generate.self,
      FetchSchema.self,
    ]
  )
}

CodegenCLI.main()
