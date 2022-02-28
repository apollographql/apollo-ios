import Foundation
import ApolloCodegenLib

public enum Target: CaseIterable {
  case starWars
  case gitHub
  case upload
  case animalKingdom
  case ccnAnimalKingdom

  public init?(name: String) {
    switch name {
    case "StarWars":
      self = .starWars
    case "GitHub":
      self = .gitHub
    case "Upload":
      self = .upload
    case "AnimalKingdom":
      self = .animalKingdom
    case "CCNAnimalKingdom":
      self = .ccnAnimalKingdom
    default:
      return nil
    }
  }

  public var moduleName: String {
    switch self {
    case .starWars: return "StarWarsAPI"
    case .gitHub: return "GitHubAPI"
    case .upload: return "UploadAPI"
    case .animalKingdom: return "AnimalKingdomAPI"
    case .ccnAnimalKingdom: return "AnimalKingdomAPICCN"
    }
  }

  var ccnEnabled: Bool {
    switch self {
    case .starWars, .gitHub, .upload, .animalKingdom: return false
    case .ccnAnimalKingdom: return true
    }
  }

  var packageName: String {
    switch self {
    case .starWars, .gitHub, .upload, .animalKingdom: return "Generated"
    case .ccnAnimalKingdom: return "GeneratedCCN"
    }
  }

  public func targetRootURL(fromSourceRoot sourceRootURL: Foundation.URL) -> Foundation.URL {
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
    case .ccnAnimalKingdom:
      return sourceRootURL
        .apollo.childFolderURL(folderName: "Sources")
        .apollo.childFolderURL(folderName: moduleName)
    }
  }

  public func inputConfig(fromSourceRoot sourceRootURL: Foundation.URL) -> ApolloCodegenConfiguration.FileInput {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)

    switch self {
    case .upload:
      let graphQLFolder = targetRootURL.apollo.childFolderURL(folderName: "graphql")

      return ApolloCodegenConfiguration.FileInput(
        schemaPath: schemaURL(fromTargetRoot: targetRootURL).path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
      
    case .starWars:
      let graphQLFolder = targetRootURL.apollo.childFolderURL(folderName: "graphql")

      return ApolloCodegenConfiguration.FileInput(
        schemaPath: schemaURL(fromTargetRoot: targetRootURL).path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )

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
        schemaPath: schemaURL(fromTargetRoot: targetRootURL).path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
    case .ccnAnimalKingdom:
      let graphQLFolder = targetRootURL.apollo.childFolderURL(folderName: "ccnGraphql")

      return ApolloCodegenConfiguration.FileInput(
        schemaPath: graphQLFolder.appendingPathComponent("AnimalSchema.graphqls").path,
        searchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
    }
  }

  public func schemaURL(fromTargetRoot targetRootURL: Foundation.URL) -> Foundation.URL {
    let graphQLFolder = targetRootURL.apollo.childFolderURL(folderName: "graphql")

    switch self {
    case .starWars:
      return graphQLFolder.appendingPathComponent("schema.graphqls")
    case .upload:
      return graphQLFolder.appendingPathComponent("schema.json")
    case .gitHub:
      fatalError("Implement!")
    case .animalKingdom:
      return graphQLFolder.appendingPathComponent("AnimalSchema.graphqls")
    }
  }

  public func outputConfig(
    fromSourceRoot sourceRootURL: Foundation.URL,
    forModuleType moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType
  ) throws -> ApolloCodegenConfiguration.FileOutput {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)

    return ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(
        path: targetRootURL.appendingPathComponent(moduleName).path,
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
    case .upload, .starWars: return true
    default: return false
    }
  }
}
