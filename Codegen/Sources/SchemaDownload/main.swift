import Foundation
import ApolloCodegenLib

enum MySchemaError: Error {
  case sourceRootNotProvided
  case sourceRootNotADirectory
  case targetDoesntExist(atURL: Foundation.URL)
}

guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
  throw MySchemaError.sourceRootNotProvided
}

guard FileManager.default.apollo_folderExists(at: sourceRootPath) else {
  throw MySchemaError.sourceRootNotADirectory
}

let sourceRootURL = URL(fileURLWithPath: sourceRootPath)
let cliFolderURL = sourceRootURL
    .appendingPathComponent("Codegen")
    .appendingPathComponent("ApolloCLI")

let endpoint = URL(string: "http://localhost:8080/graphql")!

let output = sourceRootURL
    .appendingPathComponent("Tests")
    .appendingPathComponent("StarWarsAPI")

let options = ApolloSchemaOptions(schemaFileName: "downloaded_schema",
                                  endpointURL: endpoint,
                                  outputFolderURL: output)

do {
    try ApolloSchemaDownloader.run(with: cliFolderURL,
                                   options: options)
} catch {
    exit(1)
}
