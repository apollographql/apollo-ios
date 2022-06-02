import Foundation
import ArgumentParser
import ApolloCodegenLib

struct Initialize: ParsableCommand {

  // MARK: - Configuration

  static var configuration = CommandConfiguration(
    commandName: "init",
    abstract: "Initialize a new configuration with defaults."
  )

  @Option(
    name: .shortAndLong,
    help: "Write the configuration to a file at the path."
  )
  var path: String = Constants.defaultFilePath

  @Flag(
    name: [.long, .customShort("w")],
    help: """
      Overwrite any file at --path. If init is called without --overwrite and a config file \
      already exists at --path, the command will fail.
      """
  )
  var overwrite: Bool = false

  @Flag(
    name: [.long, .customShort("s")],
    help: "Print the configuration to stdout."
  )
  var print: Bool = false

  // MARK: - Implementation

  func run() throws {
    try _run()
  }

  func _run(fileManager: FileManager = .default) throws {
    let encoded = try ApolloCodegenConfiguration
      .default
      .encoded()

    if print {
      try print(data: encoded)
      return
    }

    try write(
      data: encoded,
      toPath: path,
      overwrite: overwrite,
      fileManager: fileManager
    )
  }

  private func write(
    data: Data,
    toPath path: String,
    overwrite: Bool,
    fileManager: FileManager
  ) throws {
    if !overwrite && fileManager.apollo.doesFileExist(atPath: path) {
      throw Error(
        errorDescription: """
          File already exists at \(path). Hint: use --overwrite to overwrite any existing \
          file at the path.
          """
      )
    }

    try fileManager.apollo.createFile(
      atPath: path,
      data: data
    )

    Swift.print("New configuration output to \(path).")
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
