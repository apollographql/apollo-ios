import Foundation
import SourceDocsLib
import ApolloCodegenLib

#warning("For some reason, this is failing when run directly from Xcode instead of with `swift run DocumentationGenerator`. So use that and not Xcode to run this for now")

enum Target: String, CaseIterable {
    case Apollo
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

    
    let options = GenerateCommandOptions(moduleName: target.name,
                                         linkEndingText: "/",
                                         inputFolder: sourceRootURL.path,
                                         outputFolder: outputURL.path,
                                         clean: true,
                                         xcodeArguments: [
                                            "-scheme",
                                            target.scheme,
                                            "-project",
                                            "Apollo.xcodeproj"
                                         ])
    
    let result = GenerateCommand().run(options)
    
    switch result {
    case .success:
        CodegenLogger.log("Generated docs for \(target.name)")
    case .failure(let error):
        CodegenLogger.log("Error generating docs for \(target.name): \(error)", logLevel: .error)
        exit(1)
    }
}

