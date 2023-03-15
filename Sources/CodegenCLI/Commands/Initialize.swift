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
    name: [.long],
    help: "DEPRECATED - Use --schema-namespace instead."
  )
  // When removing this property also do:
  // - remove the initialization value for schemaNamespace
  // - remove schemaName validation in validate()
  // - remove mutating keyword from validate() signature
  var schemaName: String?

  @Option(
    name: [.long, .customShort("n")],
    help: "Name used to scope the generated schema type files."
  )
  var schemaNamespace: String = ""

  @Option(
    name: [.long, .customShort("m")],
    help: """
      How to package the schema types for dependency management. Possible types: \
      \(ModuleTypeExpressibleByArgument.allValueStrings.joined(separator: ", ")).
      """
  )
  var moduleType: ModuleTypeExpressibleByArgument

  @Option(
    name: [.long, .customShort("t")],
    help: """
      Name of the target in which the schema types files will be manually embedded. This is \
      required for the \"embeddedInTarget\" module type and will be ignored for all other module \
      types.
      """
  )
  var targetName: String? = nil

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

  public mutating func validate() throws {
    switch (moduleType, targetName?.isEmpty) {
    case (.embeddedInTarget, nil), (.embeddedInTarget, true):
      throw ValidationError("""
        Target name is required when using \"embeddedInTarget\" module type. Use --target-name \
        to specify.
        """
      )
    default:
      break;
    }

    if let schemaName {
      Swift.print("Warning: --schema-name is deprecated, please use --schema-namespace instead.")

      if !schemaNamespace.isEmpty {
        throw ValidationError("""
          Cannot specify both --schema-name and --schema-namespace. Please only use \
          --schema-namespace".
          """)
      }

      schemaNamespace = schemaName
    }
  }

  public func run() throws {
    try _run()
  }

  func _run(fileManager: ApolloFileManager = .default, output: OutputClosure? = nil) throws {
    let encoded = try ApolloCodegenConfiguration
      .minimalJSON(schemaNamespace: schemaNamespace, moduleType: moduleType, targetName: targetName)
      .asData()

    let decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded)
    try ApolloCodegen._validate(config: decoded)

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
  static func minimalJSON(
    schemaNamespace: String,
    moduleType: ModuleTypeExpressibleByArgument,
    targetName: String?
  ) -> String {
    #if COCOAPODS
      minimalJSON(
        schemaNamespace: schemaNamespace,
        supportCocoaPods: true,
        moduleType: moduleType,
        targetName: targetName
      )
    #else
      minimalJSON(
        schemaNamespace: schemaNamespace,
        supportCocoaPods: false,
        moduleType: moduleType,
        targetName: targetName
      )
    #endif
  }

  static func minimalJSON(
    schemaNamespace: String,
    supportCocoaPods: Bool,
    moduleType: ModuleTypeExpressibleByArgument,
    targetName: String?
  ) -> String {
    let cocoaPodsOption = supportCocoaPods ? """

        "options" : {
          "cocoapodsCompatibleImportStatements" : true
        },
      """ : ""

    let moduleTarget: String = {
      guard let targetName = targetName else { return "}" }

      return """
          "name" : "\(targetName)"
                }
        """
    }()

    return """
    {
      "schemaNamespace" : "\(schemaNamespace)",\(cocoaPodsOption)
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
          "path" : "./\(schemaNamespace)",
          "moduleType" : {
            "\(moduleType)" : {
            \(moduleTarget)
          }
        },
        "operations" : {
          "inSchemaModule" : {
          }
        }
      }
    }
    """
  }
}

/// A custom enum that matches ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType, but
/// specifically without associated values so that it can conform to ExpressibleByArgument and be
/// parsed from the command line.
enum ModuleTypeExpressibleByArgument: String, ExpressibleByArgument, CaseIterable {
  case embeddedInTarget
  case swiftPackageManager
  case other
}
