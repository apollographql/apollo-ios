import Foundation
import ApolloCodegenLib

public enum Target: CaseIterable {
  case starWars
  case gitHub
  case upload
  case animalKingdom
  case subscription

  public init(name: String) throws {
    switch name {
    case "StarWars": self = .starWars
    case "GitHub": self = .gitHub
    case "Upload": self = .upload
    case "AnimalKingdom": self = .animalKingdom
    case "Subscription": self = .subscription
    default: throw ArgumentError.invalidTargetName(name: name)
    }
  }

  public var moduleName: String {
    switch self {
    case .starWars: return "StarWarsAPI"
    case .gitHub: return "GitHubAPI"
    case .upload: return "UploadAPI"
    case .animalKingdom: return "AnimalKingdomAPI"
    case .subscription: return "SubscriptionAPI"
    }
  }

  public func targetRootURL(fromSourceRoot sourceRootURL: Foundation.URL) -> Foundation.URL {
    return sourceRootURL
      .childFolderURL(folderName: "Sources")
      .childFolderURL(folderName: moduleName)
  }

  public func inputConfig(
    fromSourceRoot sourceRootURL: Foundation.URL
  ) -> ApolloCodegenConfiguration.FileInput {
    let targetRootURL = self.targetRootURL(fromSourceRoot: sourceRootURL)
    let graphQLFolder = graphQLFolder(fromTargetRoot: targetRootURL)

    switch self {
    case .animalKingdom:
      return ApolloCodegenConfiguration.FileInput(
        schemaPath: graphQLFolder.appendingPathComponent("AnimalSchema.graphqls").path,
        // There is a subdirectory that contains CCN enabled operations in the same `graphQLFolder`
        // as the .animalKingdom target. We want to include those operations when we generate for
        // .animalKingdom.
        operationSearchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )

    default:
      return ApolloCodegenConfiguration.FileInput(
        schemaPath: schemaURL(fromTargetRoot: targetRootURL).path,
        operationSearchPaths: [graphQLFolder.appendingPathComponent("**/*.graphql").path]
      )
    }
  }

  private func graphQLFolder(fromTargetRoot targetRootURL: Foundation.URL) -> URL {
    switch self {
    case .starWars:
      return targetRootURL.childFolderURL(folderName: "starwars-graphql")

    case .animalKingdom:
      return targetRootURL.childFolderURL(folderName: "animalkingdom-graphql")

    default:
      return targetRootURL.childFolderURL(folderName: "graphql")
    }
  }

  public func schemaURL(fromTargetRoot targetRootURL: Foundation.URL) -> Foundation.URL {
    let graphQLFolder = graphQLFolder(fromTargetRoot: targetRootURL)

    switch self {
    case .upload:
      return graphQLFolder.appendingPathComponent("schema.json")

    case .animalKingdom:
      return graphQLFolder.appendingPathComponent("AnimalSchema.graphqls")

    default:
      return graphQLFolder.appendingPathComponent("schema.graphqls")
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
        .childFileURL(fileName: "operationIDs.json")
        .path : nil
    )
  }

  private var includeOperationIdentifiers: Bool {
    switch self {
    case .upload, .starWars, .gitHub: return true
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
    case .starWars: return .init(schemaDocumentation: .include, apqs: .automaticallyPersist)
    case .animalKingdom: return .init(schemaDocumentation: .include)
    default: return .init()
    }
  }

  public func experimentalFeatures() -> ApolloCodegenConfiguration.ExperimentalFeatures {
    switch self {
    case .starWars, .gitHub: return .init(legacySafelistingCompatibleOperations: true)
    case .animalKingdom: return .init(clientControlledNullability: true)
    default: return .init()
    }
  }
}
