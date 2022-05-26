import Foundation
import ArgumentParser
import ApolloCodegenLib

struct Generate: ParsableCommand {

  // MARK: - Configuration
  
  static var configuration = CommandConfiguration(
    abstract: "Generate Swift source code based on a code generation configuration."
  )

  @Option(
    name: .shortAndLong,
    help: "Configuration source."
  )
  var input: InputMode = .file

  @Option(
    name: .shortAndLong,
    help: "Read the configuration from a file at the path."
  )
  var path: String = Constants.defaultFilePath

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format."
  )
  var string: String?

  // MARK: - Implementation

  func validate() throws {
    switch (input, string) {
    case (.string, nil):
      throw ValidationError("Missing input string. Hint: --string cannot be empty and must be in JSON format.")
    default:
      break
    }
  }

  func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self
  ) throws {
    switch self.input {
    case .file:
      guard let data = fileManager.contents(atPath: self.path) else {
        throw Error(errorDescription: "Cannot read configuration file at \(self.path)")
      }

      try generate(data: data, codegenProvider: codegenProvider)

    case .string:
      if let string = self.string {
        try generate(data: try string.asData(), codegenProvider: codegenProvider)
      }
    }
  }

  private func generate(data: Data, codegenProvider: CodegenProvider.Type) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning
    
    try codegenProvider.build(with: configuration)
  }
}
