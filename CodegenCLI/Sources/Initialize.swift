import ArgumentParser
import ApolloCodegenLib
import Foundation

struct Initialize: ParsableCommand {

  // MARK: - Configuration

  static var configuration = CommandConfiguration(
    commandName: "init",
    abstract: "Initialize a new configuration with defaults."
  )

  @Option(
    name: .long,
    help: "Write the configuration to a file at the path."
  )
  var path: String?

  @Flag(
    name: .long,
    help: "Print the configuration in JSON format to standard output."
  )
  var print = false

  // MARK: - Implementation
  
  func validate() throws {
    if path == nil && print == false {
      throw ValidationError("You must specify at least one option.")
    }
  }

  func run() throws {
    let encoded = try ApolloCodegenConfiguration
      .default
      .encoded()

    if let path = path {
      try write(data: encoded, toPath: path)
    }

    if print {
      try print(data: encoded)
    }
  }

  func write(data: Data, toPath path: String, fileManager: FileManager = FileManager.default) throws {
    try fileManager.apollo.createFile(
      atPath: path,
      data: data
    )
  }

  func print(data: Data) throws {
    struct FormatError: LocalizedError {
      var errorDescription: String?
    }

    guard let json = String(data: data, encoding: .utf8) else {
      throw FormatError(
        errorDescription: "Could not print the configuration, the JSON was not valid UTF-8."
      )
    }

    Swift.print(json)
  }
}

// MARK: - Private extensions

fileprivate extension ApolloCodegenConfiguration {
  static var `default`: ApolloCodegenConfiguration {
    ApolloCodegenConfiguration(
      schemaName: "GraphQLSchemaName",
      input: .init(
        schemaPath: "schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: "./", moduleType: .swiftPackageManager)
      )
    )
  }

  func encoded() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
