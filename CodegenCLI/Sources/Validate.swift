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
    if path == nil && string == nil {
      throw ValidationError("""
        Missing input path and string. Hint: Use --path to specify a configuration file in JSON \
        format or --string to specify a JSON formatted configuration string.
        """
      )
    }
  }
  
  func run() throws {
    try _run()
  }

  func _run(fileManager: FileManager = .default) throws {
    if let path = self.path {
      guard let data = fileManager.contents(atPath: path) else {
        throw Error(errorDescription: "Cannot read configuration file.")
      }

      try validate(data: data)

      print("--path configuration is valid.")
    }

    if let string = self.string {
      try validate(data: try string.asData())

      print("--string configuration is valid.")
    }
  }

  private func validate(data: Data) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning

    try configuration.validate()
  }
}
