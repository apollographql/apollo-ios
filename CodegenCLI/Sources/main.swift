import Foundation
import ArgumentParser

struct CodegenCLI: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "apollo-ios-codegen",
    abstract: "A command line utility for Apollo iOS code generation.",
    version: "1.0.0",
    subcommands: [
      Initialize.self,
      Validate.self,
      Generate.self
    ]
  )
}

CodegenCLI.main()
