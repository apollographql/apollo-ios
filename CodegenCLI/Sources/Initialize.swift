import ArgumentParser
import ApolloCodegenLib
import Foundation

struct Initialize: ParsableCommand {

  /// Destination for the new configuration
  enum OutputMode: String, ExpressibleByArgument, EnumerableFlag {
    case file, print
  }

  // MARK: - Configuration

  static var configuration = CommandConfiguration(
    commandName: "init",
    abstract: "Initialize a new configuration with defaults."
  )

  @Option(
    name: .long,
    help: "Destination for the new configuration."
  )
  var output: OutputMode = .file

  @Option(
    name: .shortAndLong,
    help: "Write the configuration to a file at the path."
  )
  var path: String = Constants.defaultFilePath

  @Flag(
    name: .long,
    help: "Overwrite any file at --path."
  )
  var overwrite = false

  // MARK: - Implementation
  
  func run() throws {
    try _run()
  }

  func _run(fileManager: FileManager = FileManager.default) throws {
    let encoded = try ApolloCodegenConfiguration
      .default
      .encoded()

    switch self.output {
    case .file:
      try write(
        data: encoded,
        toPath: self.path,
        overwrite: self.overwrite,
        fileManager: fileManager
      )

    case .print:
      try print(data: encoded)
    }
  }

  private func write(
    data: Data,
    toPath path: String,
    overwrite: Bool,
    fileManager: FileManager
  ) throws {
    if !overwrite && fileManager.apollo.doesFileExist(atPath: path) {
      throw Error(
        errorDescription: "File already exists at \(path). Hint: use --overwrite to overwrite any existing file at the path."
      )
    }

    try fileManager.apollo.createFile(
      atPath: path,
      data: data
    )

    Swift.print("New configuration output to \(path)")
  }

  private func print(data: Data) throws {
    guard let json = String(data: data, encoding: .utf8) else {
      throw Error(
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
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]

    return try encoder.encode(self)
  }
}
