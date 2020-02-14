import Foundation
import ApolloCodegenLib
import TSCUtility

enum MyCodegenError: Error {
  case sourceRootNotProvided
  case sourceRootNotADirectory
  case targetDoesntExist(atURL: Foundation.URL)
}

// This gets passed in automatically when run via an Xcode Build Phase Run
// Script, but you should set it up in a local (ie, not shared) scheme for
// your machine in the .xcodeproj created by opening the `Package.swift`
// for the Codegen project.
guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
  throw MyCodegenError.sourceRootNotProvided
}

// Extra check that we've actually got a folder. This part is optional, it
// just helps figure out what might be going wrong.
guard FileManager.default.apollo_folderExists(at: sourceRootPath) else {
  throw MyCodegenError.sourceRootNotADirectory
}

// This needs to be a URL rather than a path, so we convert it
let sourceRootURL = URL(fileURLWithPath: sourceRootPath)

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
