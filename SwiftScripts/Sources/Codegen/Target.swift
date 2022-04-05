import Foundation
import ApolloCodegenLib

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

  var moduleName: String {
    switch self {
    case .starWars: return "StarWarsAPI"
    case .gitHub: return "GitHubAPI"
    case .upload: return "UploadAPI"
    case .animalKingdom: return "AnimalKingdomAPI"
    }
  }

  func targetRootURL(fromSourceRoot sourceRootURL: Foundation.URL) -> Foundation.URL {
    switch self {
    case .gitHub:
      return sourceRootURL
        .apollo.childFolderURL(folderName: "Sources")
        .apollo.childFolderURL(folderName: moduleName)
    case .starWars:
      return sourceRootURL
        .apollo.childFolderURL(folderName: "Sources")
        .apollo.childFolderURL(folderName: moduleName)
    case .upload:
      return sourceRootURL
        .apollo.childFolderURL(folderName: "Sources")
        .apollo.childFolderURL(folderName: moduleName)
    case .animalKingdom:
      return sourceRootURL
        .apollo.childFolderURL(folderName: "Sources")
        .apollo.childFolderURL(folderName: moduleName)
    }
  }

  func inputConfig(fromSourceRoot sourceRootURL: Foundation.URL) -> ApolloCodegenConfiguration.FileInput {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)

    switch self {
    case .upload:
      let graphQLFolder = targetRootURL.apollo.childFolderURL(folderName: "graphql")

      return ApolloCodegenConfiguration.FileInput(
        schemaPath: graphQLFolder.appendingPathComponent("schema.json").path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
      
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

      return ApolloCodegenConfiguration.FileInput(
        schemaPath: graphQLFolder.appendingPathComponent("AnimalSchema.graphqls").path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
    }
  }

  func outputConfig(
    fromSourceRoot sourceRootURL: Foundation.URL,
    forModuleType moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType
  ) throws -> ApolloCodegenConfiguration.FileOutput {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)

    return ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(
        path: targetRootURL.path,
        schemaName: self.moduleName,
        moduleType: moduleType
      ),
      operations: .inSchemaModule,
      operationIdentifiersPath: includeOperationIdentifiers ?
      try targetRootURL
        .apollo.childFolderURL(folderName: "graphql")
        .apollo.childFileURL(fileName: "operationIDs.json")
        .path : nil
    )
  }

  private var includeOperationIdentifiers: Bool {
    switch self {
    case .upload: return true
    default: return false
    }
  }
}
