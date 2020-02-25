import Foundation
import SourceDocsLib
import ApolloCodegenLib

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

//for target in Target.allCases {
let target = Target.ApolloWebSocket
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
    
    _ = GenerateCommand().run(options)
//}

