import Foundation
import ApolloCodegenLib
import ArgumentParser

#warning("TODO: Ensure this script keeps up with the changes to codegen!")

enum Target {
  case starWars
  case gitHub
  case upload
  case animalKingdom

  init?(name: String) {
    switch name {
    case "StarWars":
      self = .starWars
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
    case .starWars:
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

  func config(fromSourceRoot sourceRootURL: Foundation.URL) -> ApolloCodegenConfiguration {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)
    switch self {
    case .upload:
      fatalError()
//      let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")
//
//      let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
//      let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
//      let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.json")
//
//      return ApolloCodegenOptions(operationIDsURL: operationIDsURL,
//                                  outputFormat: .singleFile(atFileURL: outputFileURL),
//                                  urlToSchemaFile: schema)
    case .starWars:
      fatalError()
//      let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")
//
//      let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
//      let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
//      let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.json")
//
//      return ApolloCodegenOptions(operationIDsURL: operationIDsURL,
//                                  outputFormat: .singleFile(atFileURL: outputFileURL),
//                                  urlToSchemaFile: schema)
    case .gitHub:
      fatalError()
//      let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")
//
//      let graphQLFolderURL = targetRootURL.apollo.childFolderURL(folderName: "graphql")
//      let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.docs.graphql")
//      let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
//      return ApolloCodegenOptions(includes: "graphql/Queries/**/*.graphql",
//                                  mergeInFieldsFromFragmentSpreads: true,
//                                  operationIDsURL: operationIDsURL,
//                                  outputFormat: .singleFile(atFileURL: outputFileURL),
//                                  suppressSwiftMultilineStringLiterals: true,
//                                  urlToSchemaFile: schema)
    case .animalKingdom:
      let graphQLFolder = targetRootURL.apollo.childFolderURL(folderName: "graphql")

      let input = ApolloCodegenConfiguration.FileInput(
        schemaPath: graphQLFolder.appendingPathComponent("AnimalSchema.graphqls").path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )

      let output = ApolloCodegenConfiguration.FileOutput(
        schemaTypes: .init(
          path: targetRootURL.appendingPathComponent("Generated").path,
          dependencyAutomation: .manuallyLinked(namespace: "AnimalKingdomAPI")
        ),
        operations: .inSchemaModule,
        operationIdentifiersPath: nil
      )

      return ApolloCodegenConfiguration(input: input, output: output)
    }
  }
}
