import Foundation
import ArgumentParser
import ApolloCodegenLib

struct Validate: ParsableCommand {

  // MARK: - Configuration
  
  static var configuration = CommandConfiguration(
    abstract: "Validate a configuration file or JSON formatted string."
  )

  @Option(
    name: .shortAndLong,
    help: "Configuration source."
  )
  var input: InputMode

  @Option(
    name: .shortAndLong,
    help: "Read the configuration from a file at the path."
  )
  var path: String?

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format."
  )
  var string: String?

  // MARK: - Implementation

  func validate() throws {
    switch (input, path, string) {
    case (.file, nil, _):
      throw ValidationError("Missing input file. Hint: --path cannot be empty and must be a JSON formatted configuration file.")
    case (.string, _, nil):
      throw ValidationError("Missing input string. Hint: --string cannot be empty and must be in JSON format.")
    default:
      break
    }
  }
  
  func run() throws {
    try _run()
  }

  func _run(fileManager: FileManager = .default) throws {
    switch self.input {
    case .file:
      guard
        let path = self.path,
        let data = fileManager.contents(atPath: path)
      else {
        throw Error(errorDescription: "Cannot read configuration file.")
      }

      try validate(data: data)

    case .string:
      if let string = self.string {
        try validate(data: try string.asData())
      }
    }
  }

  private func validate(data: Data) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning

    try configuration.validate()

    print("The configuration is valid.")
  }
}
