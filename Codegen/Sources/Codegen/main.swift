import Foundation
import ApolloCodegenLib
import TSCUtility

enum MyCodegenError: Error {
  case sourceRootNotProvided
  case sourceRootNotADirectory
  case targetDoesntExist(atURL: Foundation.URL)
}

guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
  throw MyCodegenError.sourceRootNotProvided
}

guard FileManager.default.apollo_folderExists(at: sourceRootPath) else {
  throw MyCodegenError.sourceRootNotADirectory
}

let sourceRootURL = URL(fileURLWithPath: sourceRootPath)

let target = try ArgumentSetup.parse()

let targetURL = target.targetRootURL(fromSourceRoot: sourceRootURL)
let options = target.options(fromSourceRoot: sourceRootURL)

guard FileManager.default.apollo_folderExists(at: targetURL) else {
  throw MyCodegenError.targetDoesntExist(atURL: targetURL)
}

let cliFolderURL = sourceRootURL
    .appendingPathComponent("Codegen")
    .appendingPathComponent("ApolloCLI")

do {
  let result = try ApolloCodegen.run(from: targetURL,
                                     with: cliFolderURL,
                                     options: options)
  print("RESULT: \(result)")
} catch {
  print("ERROR: \(error)")
  exit(1)
}

