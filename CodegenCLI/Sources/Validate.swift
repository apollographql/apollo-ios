import ArgumentParser
import Foundation
import ApolloCodegenLib

struct Validate: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Validate a configuration."
  )

  @Option(
    name: .shortAndLong,
    help: "Path to JSON configuration file."
  )
  var path: String?

  @Option(
    name: .shortAndLong,
    help: "JSON string"
  )
  var json: String?
  
  func run() throws {
    if let path = path {
      try validate(path: path)
    }

    if let json = json {
      try validate(json: json)
    }
  }

  func validate(path: String) throws {
    try validate(json: try String(contentsOfFile: path))
  }

  func validate(json: String) throws {
    guard let data = json.data(using: .utf8) else {
      throw ValidationError("Badly encoded string, should be UTF-8!")
    }

    let config = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    try config.validate()

    print("🎉 Success, the configuration is valid! 🎉")
  }
}
