import Foundation
import ApolloCodegenLib

// Grab the parent folder of this file on the filesystem
let parentFolderOfScriptFile = FileFinder.findParentFolder()

// Use that to calculate the source root
let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // SwiftScripts
    .deletingLastPathComponent() // apollo-ios

let cliFolderURL = sourceRootURL
    .appendingPathComponent("SwiftScripts")
    .appendingPathComponent("ApolloCLI")

let endpoint = URL(string: "http://localhost:4000/")!

let output = sourceRootURL
    .appendingPathComponent("Sources")
    .appendingPathComponent("UploadAPI")

let options = ApolloSchemaOptions(schemaFileName: "schema",
                                  endpointURL: endpoint,
                                  outputFolderURL: output)

do {
    try ApolloSchemaDownloader.run(with: cliFolderURL,
                                   options: options)
} catch {
    exit(1)
}
