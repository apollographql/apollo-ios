import Foundation
import ApolloCodegenLib

enum Target: String, CaseIterable {
  case Apollo
  case ApolloAPI
  case ApolloUtils
  case ApolloSQLite
  case ApolloWebSocket
  case ApolloCodegenLib

  var name: String {
    self.rawValue
  }
  
  var scheme: String {
    self.rawValue
  }

  var docBuildCommand: String {
    "xcodebuild -project Apollo.xcodeproj -derivedDataPath docs/docc/tmp -scheme \(scheme) docbuild"
  }
}

// Grab the parent folder of this file on the filesystem
let parentFolderOfScriptFile = FileFinder.findParentFolder()

// Use that to calculate the source root
let sourceRootURL = parentFolderOfScriptFile
  .deletingLastPathComponent() // Sources
  .deletingLastPathComponent() // SwiftScripts
  .deletingLastPathComponent() // apollo-ios

@discardableResult
func shell(_ command: String) throws -> String {
  let task = Process()
  let pipe = Pipe()

  task.standardOutput = pipe
  task.standardError = pipe
  task.currentDirectoryURL = sourceRootURL
  task.arguments = ["-c", command]
  task.executableURL = URL(fileURLWithPath: "/bin/zsh")
  task.standardInput = nil

  try task.run()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)!

  return output
}

func run() {
  let doccFolder = sourceRootURL.appendingPathComponent("docs/docc")
  let doccTempFolder = doccFolder.appendingPathComponent("tmp")
  let doccProductsFolder = doccTempFolder.appendingPathComponent("Build/Products/Debug")

  for target in Target.allCases {
    do {
      try shell(target.docBuildCommand)

      let doccArchiveFileFromURL = doccProductsFolder
        .appendingPathComponent(target.name)
        .appendingPathExtension("doccarchive")

      let doccArchiveFileToURL = doccFolder
        .appendingPathComponent(target.name)
        .appendingPathExtension("doccarchive")

      if FileManager.default.fileExists(atPath: doccArchiveFileToURL.path) {
        try FileManager.default.removeItem(at: doccArchiveFileToURL)
      }

      try FileManager.default.moveItem(at: doccArchiveFileFromURL, to: doccArchiveFileToURL)

      CodegenLogger.log("Generated docs for \(target.name)")

    } catch {
      CodegenLogger.log("Error generating docs for \(target.name): \(error)", logLevel: .error)
      exit(1)
    }
  }

  do {
    try FileManager.default.removeItem(at: doccTempFolder)
  } catch {
    CodegenLogger.log("Error deleting 'docs/docc/tmp' directory: \(error)", logLevel: .error)
    exit(1)
  }
}

run()
