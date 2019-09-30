//
//  main.swift
//  ApolloCodegen
//
//  Created by Ellen Shapiro on 9/25/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation
import ApolloCodegenLib

enum CodegenError: Error {
  case sourceRootNotProvided
  case sourceRootNotADirectory
  case doesntExist
}

guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
  throw CodegenError.sourceRootNotProvided
}

guard FileManager.default.apollo_folderExists(at: sourceRootPath) else {
  throw CodegenError.sourceRootNotADirectory
}

let sourceRootURL = URL(fileURLWithPath: sourceRootPath)

let starWarsTarget = sourceRootURL.appendingPathComponent("Tests").appendingPathComponent("StarWarsAPI")

guard FileManager.default.apollo_folderExists(at: starWarsTarget) else {
  throw CodegenError.doesntExist
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

