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

  var docHostingBasePath: String {
    switch self {
    case .Apollo: return "apollo"
    case .ApolloAPI: return "api"
    case .ApolloUtils: return "utils"
    case .ApolloSQLite: return "sqlite"
    case .ApolloWebSocket: return "web-socket"
    case .ApolloCodegenLib: return "codegen-lib"
    }
  }

}

struct DocumentationGenerator {
  static func main() {
    for target in Target.allCases {
      do {
        try shell(docBuildCommand(for: target))
        CodegenLogger.log("Generated docs for \(target.name)")
        try moveDocsIntoApolloDocCArchive(for: target)
        
      } catch {
        CodegenLogger.log("Error generating docs for \(target.name): \(error)", logLevel: .error)
        exit(1)
      }
    }
  }

  // Grab the parent folder of this file on the filesystem
  static let parentFolderOfScriptFile = FileFinder.findParentFolder()

  // Use that to calculate the source root
  static let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // SwiftScripts
    .deletingLastPathComponent() // apollo-ios

  static let doccFolder = sourceRootURL.appendingPathComponent("docs/docc")

  static func docBuildCommand(for target: Target) -> String {
    let outputPath = doccFolder
      .appendingPathComponent(target.name)
      .appendingPathExtension("doccarchive")

    return """
    swift package \
    --allow-writing-to-directory \(outputPath.relativePath) \
    generate-documentation \
    --target \(target.name) \
    --disable-indexing \
    --output-path \(outputPath.relativePath) \
    --hosting-base-path docs/ios/docc/\(target.docHostingBasePath)
    """
  }

  static func shell(_ command: String) throws {
    let task = Process()
    let pipe = Pipe()
    let outHandle = pipe.fileHandleForReading
    outHandle.readabilityHandler = { pipe in
      if let line = String(data: pipe.availableData, encoding: .utf8), !line.isEmpty {
        CodegenLogger.log(line, logLevel: .debug)
      }
    }

    task.environment = ProcessInfo.processInfo.environment
    task.standardOutput = pipe
    task.standardError = pipe

    task.currentDirectoryURL = sourceRootURL.appendingPathComponent("SwiftScripts")
    task.environment?["OS_ACTIVITY_DT_MODE"] = nil
    task.environment?["DOCC_JSON_PRETTYPRINT"] = "YES"
    task.environment?["DOCC_HTML_DIR"] = sourceRootURL
      .deletingLastPathComponent()
      .appendingPathComponent("ThirdParty/swift-docc-render/dist").relativePath
    task.arguments = ["-c", command]

    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    try task.run()
    task.waitUntilExit()
  }

  static func moveDocsIntoApolloDocCArchive(for target: Target) throws {
    guard target != .Apollo else { return }

    let docsFromURL = doccFolder
      .appendingPathComponent("\(target.name).doccarchive/data/documentation/\(target.name.lowercased())")
    let docsToURL = doccFolder
      .appendingPathComponent("Apollo.doccarchive/data/documentation/\(target.name.lowercased())")
    try FileManager.default.moveItem(at: docsFromURL, to: docsToURL)

    let indexJSONFromURL = doccFolder
      .appendingPathComponent("\(target.name).doccarchive/data/documentation/\(target.name.lowercased()).json")
    let indexJSONToURL = doccFolder
      .appendingPathComponent("Apollo.doccarchive/data/documentation/\(target.name.lowercased()).json")
    try FileManager.default.moveItem(at: indexJSONFromURL, to: indexJSONToURL)
  }

}

DocumentationGenerator.main()
