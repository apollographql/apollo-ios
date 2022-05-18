import ArgumentParser
import ApolloCodegenLib
import Foundation

struct Initialize: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "init",
    abstract: "Initialize a new configuration"
  )

  @Option(
    name: .long,
    help: "Configuration file output path"
  )
  var path: String?

  @Flag(
    help: "Print configuration file as JSON"
  )
  var print = false

  mutating func run() throws {
    let config = ApolloCodegenConfiguration(
      schemaName: "GraphQLSchemaName",
      input: .init(
        schemaPath: "schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: "./", moduleType: .swiftPackageManager)
      )
    )

    let encoded = try JSONEncoder().encode(config)

    if let path = path {
      try FileManager.default.apollo.createFile(
        atPath: path,
        data: encoded
      )
    }

    if print, let json = String(data: encoded, encoding: .utf8) {
      Swift.print(json)
    }
  }
}

