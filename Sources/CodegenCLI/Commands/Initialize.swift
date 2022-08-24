import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct Initialize: ParsableCommand {

  // MARK: - Configuration

  public static var configuration = CommandConfiguration(
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

  typealias OutputClosure = ((String) -> ())

  public init() { }

  public func run() throws {
    try _run()
  }

  func _run(fileManager: ApolloFileManager = .default, output: OutputClosure? = nil) throws {
    let encoded = try ApolloCodegenConfiguration
      .default
      .encoded()

    if print {
      try print(data: encoded, output: output)
      return
    }

    try write(
      data: encoded,
      toPath: path,
      overwrite: overwrite,
      fileManager: fileManager,
      output: output
    )
  }

  private func write(
    data: Data,
    toPath path: String,
    overwrite: Bool,
    fileManager: ApolloFileManager,
    output: OutputClosure? = nil
  ) throws {
    if !overwrite && fileManager.doesFileExist(atPath: path) {
      throw Error(
        errorDescription: """
          File already exists at \(path). Hint: use --overwrite to overwrite any existing \
          file at the path.
          """
      )
    }

    try fileManager.createFile(
      atPath: path,
      data: data
    )

    print(message: "New configuration output to \(path).", output: output)
  }

  private func print(data: Data, output: OutputClosure? = nil) throws {
    guard let json = String(data: data, encoding: .utf8) else {
      throw Error(
        errorDescription: "Could not print the configuration, the JSON was not valid UTF-8."
      )
    }

    print(message: json, output: output)
  }

  private func print(message: String, output: OutputClosure? = nil) {
    if let output = output {
      output(message)
    } else {
      Swift.print(message)
    }
  }
}

// MARK: - Private extensions

fileprivate extension ApolloCodegenConfiguration {
  static var `default`: ApolloCodegenConfiguration {
    #if COCOAPODS
    ApolloCodegenConfiguration(
      schemaName: "GraphQLSchemaName",
      input: .init(
        schemaPath: "schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: "./", moduleType: .swiftPackageManager)
      ),
      options: .init(cocoapodsCompatibleImportStatements: true)
    )
    #else
    ApolloCodegenConfiguration(
      schemaName: "GraphQLSchemaName",
      input: .init(
        schemaPath: "schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: "./", moduleType: .swiftPackageManager)
      )
    )
    #endif
  }

  func encoded() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]

    return try encoder.encode(self)
  }
}
