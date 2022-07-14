import Foundation
import ApolloCodegenLib

public enum Target: CaseIterable {
  case starWars
//  case gitHub
  case upload
  case animalKingdom
  case subscription

  public init(name: String) throws {
    switch name {
    case "StarWars":
      self = .starWars
//    case "GitHub":
//      self = .gitHub
    case "Upload":
      self = .upload
    case "AnimalKingdom":
      self = .animalKingdom
    case "Subscription":
      self = .subscription
    default:
      throw ArgumentError.invalidTargetName(name: name)
    }
  }

  public var moduleName: String {
    switch self {
    case .starWars: return "StarWarsAPI"
//    case .gitHub: return "GitHubAPI"
    case .upload: return "UploadAPI"
    case .animalKingdom: return "AnimalKingdomAPI"
    case .subscription: return "SubscriptionAPI"
    }
  }

  public func targetRootURL(fromSourceRoot sourceRootURL: Foundation.URL) -> Foundation.URL {
    switch self {
//    case .gitHub:
//      return sourceRootURL
//        .apollo.childFolderURL(folderName: "Sources")
//        .apollo.childFolderURL(folderName: moduleName)
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
    case .subscription:
      return sourceRootURL
        .apollo.childFolderURL(folderName: "Sources")
        .apollo.childFolderURL(folderName: moduleName)
    }
  }

  public func inputConfig(fromSourceRoot sourceRootURL: Foundation.URL) -> ApolloCodegenConfiguration.FileInput {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)
    let graphQLFolder = graphQLFolder(fromTargetRoot: targetRootURL)

    switch self {
    case .upload, .starWars, .subscription:
      return ApolloCodegenConfiguration.FileInput(
        schemaPath: schemaURL(fromTargetRoot: targetRootURL).path,
        operationSearchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
      
//    case .gitHub:
//      let outputFileURL = try!  targetRootURL.apollo.childFileURL(fileName: "API.swift")
//
//      let schema = try! graphQLFolderURL.apollo.childFileURL(fileName: "schema.docs.graphql")
//      let operationIDsURL = try! graphQLFolderURL.apollo.childFileURL(fileName: "operationIDs.json")
//      return ApolloCodegenOptions(includes: "graphql/Queries/**/*.graphql",
//                                  mergeInFieldsFromFragmentSpreads: true,
//                                  operationIDsURL: operationIDsURL,
//                                  outputFormat: .singleFile(atFileURL: outputFileURL),
//                                  suppressSwiftMultilineStringLiterals: true,
//                                  urlToSchemaFile: schema)
    case .animalKingdom:
      return ApolloCodegenConfiguration.FileInput(
        schemaPath: graphQLFolder.appendingPathComponent("AnimalSchema.graphqls").path,
        // There is a subdirectory that contains CCN enabled operations in the same `graphQLFolder` as
        //   the .animalKingdom target. We want to include those operations when we generate for
        //   .animalKingdom.
        operationSearchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
    }
  }

  private func graphQLFolder(fromTargetRoot targetRootURL: Foundation.URL) -> URL {
    switch self {
    case .starWars:
      return targetRootURL.apollo.childFolderURL(folderName: "starwars-graphql")
    case .animalKingdom:
      return targetRootURL.apollo.childFolderURL(folderName: "animalkingdom-graphql")
    default:
      return targetRootURL.apollo.childFolderURL(folderName: "graphql")
    }
  }

  public func schemaURL(fromTargetRoot targetRootURL: Foundation.URL) -> Foundation.URL {
    let graphQLFolder = graphQLFolder(fromTargetRoot: targetRootURL)

    switch self {
    case .starWars, .subscription:
      return graphQLFolder.appendingPathComponent("schema.graphqls")
    case .upload:
      return graphQLFolder.appendingPathComponent("schema.json")
//    case .gitHub:
//      fatalError("Implement!")
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
        moduleType: moduleType
      ),
      operations: .inSchemaModule,
      testMocks: includeTestMocks ? .swiftPackage() : .none,
      operationIdentifiersPath: includeOperationIdentifiers ?
      try graphQLFolder(fromTargetRoot: targetRootURL)
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

  private var includeTestMocks: Bool {
    switch self {
    case .animalKingdom: return true
    default: return false
    }
  }

  public func options() -> ApolloCodegenConfiguration.OutputOptions {
    switch self {
    case .starWars:
      return .init(schemaDocumentation: .include, apqs: .automaticallyPersist)

    case .animalKingdom:
      return .init(schemaDocumentation: .include)
      
    default:
      return .init()
    }
  }

  public func experimentalFeatures() -> ApolloCodegenConfiguration.ExperimentalFeatures {
    switch self {
    case .starWars:
      return .init(legacySafelistingCompatibleOperations: true)

    case .animalKingdom:
      return .init(clientControlledNullability: true)

    default:
      return .init()
    }
  }
}
