#!/usr/bin/env xcrun swift -F ../build/Debug

import Foundation
import ApolloCodegenLib

enum MyCodegenError: Error {
  case sourceRootNotProvided
  case sourceRootNotADirectory
  case doesntExist
}

guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
  throw MyCodegenError.sourceRootNotProvided
}

guard FileManager.default.apollo_folderExists(at: sourceRootPath) else {
  throw MyCodegenError.sourceRootNotADirectory
}

let sourceRootURL = URL(fileURLWithPath: sourceRootPath)

let starWarsTarget = sourceRootURL.appendingPathComponent("Tests").appendingPathComponent("StarWarsAPI")

guard FileManager.default.apollo_folderExists(at: starWarsTarget) else {
  throw MyCodegenError.doesntExist
}

let binaryFolderURL = sourceRootURL
  .appendingPathComponent("scripts")
  .appendingPathComponent("apollo")
  .appendingPathComponent("bin")

do {
  let result = try ApolloCodegen.run(from: starWarsTarget,
                                     binaryFolderURL: binaryFolderURL)
  print("RESULT: \(result)")
} catch {
  print("ERROR: \(error)")
}

