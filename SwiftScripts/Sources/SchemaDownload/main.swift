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

// Introspection download:
let configuration = ApolloSchemaDownloadConfiguration(using: .introspection(endpointURL: endpoint),
                                                      outputFolderURL: output,
                                                      schemaFilename: "schema")

// Registry download:
//let registrySettings = ApolloSchemaDownloadConfiguration.DownloadMethod.RegistrySettings(apiKey: <#Replace Me For Testing#>,
//                                                                                         graphID: "Apollo-Fullstack-8zo5jl")
//
//let configuration = ApolloSchemaDownloadConfiguration(using: .registry(registrySettings),
//                                                      outputFolderURL: output,
//                                                      schemaFilename: "schema")

do {
    try ApolloSchemaDownloader.run(with: cliFolderURL,
                                   configuration: configuration)
} catch {
    exit(1)
}
