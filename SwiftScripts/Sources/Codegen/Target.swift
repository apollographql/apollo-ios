import Foundation
import ApolloCodegenLib
import ArgumentParser

enum Target {
    case starWars
    case starWarsSwiftCodegen
    case gitHub
    case upload
    case animalKingdom
    
    init?(name: String) {
        switch name {
        case "StarWars":
            self = .starWars
        case "StarWars-SwiftCodegen":
            self = .starWarsSwiftCodegen
        case "GitHub":
            self = .gitHub
        case "Upload":
            self = .upload
        case "AnimalKingdom":
            self = .animalKingdom
        default:
            return nil
        }
    }
    
    func targetRootURL(fromSourceRoot sourceRootURL: Foundation.URL) -> Foundation.URL {
        switch self {
        case .gitHub:
            return sourceRootURL
                .apollo.childFolderURL(folderName: "Sources")
                .apollo.childFolderURL(folderName: "GitHubAPI")
        case .starWars,
             .starWarsSwiftCodegen:
            return sourceRootURL
                .apollo.childFolderURL(folderName: "Sources")
                .apollo.childFolderURL(folderName: "StarWarsAPI")
        case .upload:
            return sourceRootURL
            .apollo.childFolderURL(folderName: "Sources")
            .apollo.childFolderURL(folderName: "UploadAPI")
        case .animalKingdom:
            return sourceRootURL
            .apollo.childFolderURL(folderName: "Sources")
            .apollo.childFolderURL(folderName: "AnimalKingdomAPI")
        }
    }
    
    func options(fromSourceRoot sourceRootURL: Foundation.URL) -> ApolloCodegenOptions {
        let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)
        switch self {
        case .upload:
            let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")

            let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
            let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
            let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.json")
            return ApolloCodegenOptions(operationIDsURL: operationIDsURL,
                                        outputFormat: .singleFile(atFileURL: outputFileURL),
                                        urlToSchemaFile: schema)
        case .starWars:
            let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")

            let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
            let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
            let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.json")
            
            return ApolloCodegenOptions(operationIDsURL: operationIDsURL,
                                        outputFormat: .singleFile(atFileURL: outputFileURL),
                                        urlToSchemaFile: schema)
        case .starWarsSwiftCodegen:
            let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
            let jsonOutputFileURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "API.json")
            let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
            let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.json")
            
            return ApolloCodegenOptions(codegenEngine: .swiftExperimental,
                                        operationIDsURL: operationIDsURL,
                                        outputFormat: .singleFile(atFileURL: jsonOutputFileURL),
                                        urlToSchemaFile: schema)
        case .gitHub:
            let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")

            let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
            let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.docs.graphql")
            let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
            return ApolloCodegenOptions(includes: "graphql/Queries/**/*.graphql",
                                        mergeInFieldsFromFragmentSpreads: true,
                                        operationIDsURL: operationIDsURL,
                                        outputFormat: .singleFile(atFileURL: outputFileURL),
                                        suppressSwiftMultilineStringLiterals: true,
                                        urlToSchemaFile: schema)
        case .animalKingdom:
            let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
            let outputFolderURL = graphQLFolderURL.apollo.childFolderURL(folderName: "Generated")
            let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.graphqls")

            return ApolloCodegenOptions(codegenEngine: .swiftExperimental,
                                        outputFormat: .multipleFiles(inFolderAtURL: outputFolderURL),
                                        urlToSchemaFile: schema)
        }
    }
}
