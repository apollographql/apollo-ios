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
    name: [.long, .customShort("n")],
    help: "Name used to scope the generated schema type files."
  )
  var schemaName: String = ""

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

  public func validate() throws {
    guard !schemaName.isEmpty else {
      throw ValidationError("Schema name is missing, use the --schema-name option to specify.")
    }
  }

  public func run() throws {
    try _run()
  }

  func _run(fileManager: ApolloFileManager = .default, output: OutputClosure? = nil) throws {
    let encoded = try ApolloCodegenConfiguration
      .minimalJSON(schemaName: schemaName)
      .asData()

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

// MARK: - Internal extensions

extension ApolloCodegenConfiguration {
  static func minimalJSON(schemaName: String) -> String {
    #if COCOAPODS
      minimalJSON(schemaName: schemaName, supportCocoaPods: true)
    #else
      minimalJSON(schemaName: schemaName, supportCocoaPods: false)
    #endif
  }

  static func minimalJSON(schemaName: String, supportCocoaPods: Bool) -> String {
    let cocoaPodsOption = supportCocoaPods ? """

        "options" : {
          "cocoapodsCompatibleImportStatements" : true
        },
      """ : ""

    return """
    {
      "schemaName" : "\(schemaName)",\(cocoaPodsOption)
      "input" : {
        "operationSearchPaths" : [
          "**/*.graphql"
        ],
        "schemaSearchPaths" : [
          "**/*.graphqls"
        ]
      },
      "output" : {
        "testMocks" : {
          "none" : {
          }
        },
        "schemaTypes" : {
          "path" : "./",
          "moduleType" : {
            "swiftPackageManager" : {
            }
          }
        },
        "operations" : {
          "relative" : {
          }
        }
      }
    }
    """
  }
}
