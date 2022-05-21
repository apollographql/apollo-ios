import ArgumentParser
import Foundation
import ApolloCodegenLib

struct Generate: ParsableCommand {

  // MARK: - Configuration
  
  static var configuration = CommandConfiguration(
    abstract: "Generate Swift source code based on a code generation configuration."
  )

  @Option(
    name: .shortAndLong,
    help: "Path to a configuration file."
  )
  var path: String?

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format."
  )
  var json: String?

  // MARK: - Implementation

  func validate() throws {
    if path == nil && json == nil {
      throw ValidationError("You must specify a configuration source.")
    }

    if let _ = path, let _ = json {
      throw ValidationError("You can only specify one configuration source.")
    }
  }

  func run() throws {
    if let path = path {
      try generate(path: path)
    }

    if let json = json {
      try generate(json: json)
    }
  }

  func generate(path: String) throws {
    try generate(data: try String(contentsOfFile: path).asData())
  }

  func generate(json: String) throws {
    try generate(data: try json.asData())
  }

  private func generate(data: Data) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    try ApolloCodegen.build(with: configuration)
  }
}
