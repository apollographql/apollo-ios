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
    help: "Read the configuration from a file at the path."
  )
  var path: String = Constants.defaultFilePath

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format."
  )
  var string: String?

  // MARK: - Implementation

  func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self
  ) throws {
    if let string = string {
      try generate(data: try string.asData(), codegenProvider: codegenProvider)
      return
    }

    guard let data = fileManager.contents(atPath: path) else {
      throw Error(errorDescription: "Cannot read configuration file at \(path)")
    }

    try generate(data: data, codegenProvider: codegenProvider)
  }

  private func generate(data: Data, codegenProvider: CodegenProvider.Type) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning
    
    try codegenProvider.build(with: configuration)
  }
}
