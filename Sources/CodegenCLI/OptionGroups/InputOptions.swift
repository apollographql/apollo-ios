import Foundation
import ArgumentParser
import ApolloCodegenLib

/// Shared group of common arguments used in commands for input parameters.
struct InputOptions: ParsableArguments {
  @Option(
    name: .shortAndLong,
    help: """
      Read the configuration from a file at the path. --string overrides this option if used \
      together.
      """
  )
  var path: String = Constants.defaultFilePath

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format. This option overrides --path."
  )
  var string: String?

  @Flag(
    name: .shortAndLong,
    help: "Increase verbosity to include debug output."
  )
  var verbose: Bool = false
  
  @Flag(
    name: .long,
    help: "Ignore Apollo version mismatch errors. Warning: This may lead to incompatible generated objects."
  )
  var ignoreVersionMismatch: Bool = false

  func getCodegenConfiguration(fileManager: FileManager) throws -> ApolloCodegenConfiguration {
    var data: Data
    switch (string, path) {
    case let (.some(string), _):
      data = try string.asData()

    case let (nil, path):
      data = try fileManager.unwrappedContents(atPath: path)
    }
    return try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)
  }
}
