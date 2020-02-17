import Foundation
import ApolloCodegenLib
import TSCUtility

enum MyCodegenError: Error {
  case targetDoesntExist(atURL: Foundation.URL)
}

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // Codegen
    .deletingLastPathComponent() // apollo-ios

// In a typical app, you'll only need to do this for one target, so you'd
// set these up directly within this file. Here, we're using more than one
// target, so we're using an arg parser to figure out which one to build,
// and an enum to hold related options.
let target = try ArgumentSetup.parse()
let targetURL = target.targetRootURL(fromSourceRoot: sourceRootURL)
let options = target.options(fromSourceRoot: sourceRootURL)

// This more necessary if you're using a sub-folder, but make sure
// there's actually a place to write out what you're doing.
try FileManager.default.apollo_createFolderIfNeeded(at: targetURL)

// Calculate where you want to download the CLI folder.
let cliFolderURL = sourceRootURL
    .appendingPathComponent("Codegen")
    .appendingPathComponent("ApolloCLI")

do {
    // Actually attempt to generate code.
    try ApolloCodegen.run(from: targetURL,
                          with: cliFolderURL,
                          options: options)
} catch {
    // This makes the error message in Xcode a lot more legible.
    exit(1)
}
