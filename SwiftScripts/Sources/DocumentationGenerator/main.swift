import Foundation
import SourceDocsLib
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
    
    var outputFolder: String {
        self.rawValue
    }
}

// Grab the parent folder of this file on the filesystem
let parentFolderOfScriptFile = FileFinder.findParentFolder()

// Use that to calculate the source root
let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // SwiftScripts
    .deletingLastPathComponent() // apollo-ios

for target in Target.allCases {
    // Figure out where to put the docs for the current target.
    let outputURL = sourceRootURL
        .appendingPathComponent("docs")
        .appendingPathComponent("source")
        .appendingPathComponent("api")
        .appendingPathComponent(target.outputFolder)

    let options = DocumentOptions(allModules: false,
                                  spmModule: nil,
                                  moduleName: target.name,
                                  linkEndingText: "/",
                                  inputFolder: sourceRootURL.path,
                                  outputFolder: outputURL.path,
                                  clean: true,
                                  xcodeArguments: [
                                    "-scheme",
                                    target.scheme,
                                    "-project",
                                    "Apollo.xcodeproj"
                                  ],
                                  reproducibleDocs: true)
    
    do {
        try SourceDocsLib.DocumentationGenerator(options: options).run()
        CodegenLogger.log("Generated docs for \(target.name)")
    } catch {
        CodegenLogger.log("Error generating docs for \(target.name): \(error)", logLevel: .error)
        exit(1)
    }
}

