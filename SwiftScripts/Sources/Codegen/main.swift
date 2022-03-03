import Foundation
import ApolloCodegenLib
import ArgumentParser

// In a typical app, you'll only need to do this for one target, so you'd
// set these up directly within this file. Here, we're using more than one
// target, so we're using an arg parser to figure out which one to build,
// and an enum to hold related options.
struct Codegen: ParsableCommand {
    
    enum ArgumentError: Error, LocalizedError {
        case invalidTargetName(name: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidTargetName(let name):
                return "The target \"\(name)\" was invalid. Please try again."
            }
        }
    }
    
    @Option(name: [.customLong("target"), .customShort("t")], help: "The target to generate code for. Required.")
    var targetName: String
    
    mutating func run() throws {
        guard let target = Target(name: targetName) else {
            throw ArgumentError.invalidTargetName(name: targetName)
        }
        
        // Grab the parent folder of this file on the filesystem
        let parentFolderOfScriptFile = FileFinder.findParentFolder()

        // Use that to calculate the source root
        let sourceRootURL = parentFolderOfScriptFile
            .apollo.parentFolderURL() // Sources
            .apollo.parentFolderURL() // SwiftScripts
            .apollo.parentFolderURL() // apollo-ios
        
        let targetURL = target.targetRootURL(fromSourceRoot: sourceRootURL)
        let options = target.options(fromSourceRoot: sourceRootURL)

        // This more necessary if you're using a sub-folder, but make sure
        // there's actually a place to write out what you're doing.
        try FileManager.default.apollo.createFolderIfNeeded(at: targetURL)

        // Calculate where you want to download the CLI folder.
        let cliFolderURL = sourceRootURL
            .apollo.childFolderURL(folderName: "SwiftScripts")
            .apollo.childFolderURL(folderName: "ApolloCLI")

        // Actually attempt to generate code.
        try ApolloCodegen.run(from: targetURL,
                              with: cliFolderURL,
                              options: options)
    }
}

Codegen.main()
