import Foundation
import ArgumentParser
import ApolloCodegenLib

struct Validate: ParsableCommand {

  // MARK: - Configuration
  
  static var configuration = CommandConfiguration(
    abstract: "Validate a configuration file or JSON formatted string."
  )

  @OptionGroup var inputs: InputOptions

  // MARK: - Implementation

  func run() throws {
    try _run()
  }

  func _run(fileManager: FileManager = .default) throws {
    switch (inputs.string, inputs.path) {
    case let (.some(string), _):
      try validate(data: try string.asData())

    case let (nil, path):
      let data = try fileManager.unwrappedContents(atPath: path)
      try validate(data: data)
    }
  }

  private func validate(data: Data) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning

    try configuration.validate()

    print("The configuration is valid.")
  }
}
