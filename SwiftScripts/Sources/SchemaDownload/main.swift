import Foundation
import ApolloCodegenLib
import TargetConfig

for target in Target.allCases {

  guard let endpoint = target.serverEndpoint else {
    continue
  }

  // Grab the parent folder of this file on the filesystem
  let parentFolderOfScriptFile = FileFinder.findParentFolder()

  // Use that to calculate the source root
  let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // SwiftScripts
    .deletingLastPathComponent() // apollo-ios

  let targetURL = target.targetRootURL(fromSourceRoot: sourceRootURL)
  let outputURL = target.schemaURL(fromTargetRoot: targetURL)

  // Introspection download:
  let configuration = ApolloSchemaDownloadConfiguration(
    using: .introspection(endpointURL: endpoint),
    outputPath: outputURL.path)

  // Registry download:
  //let registrySettings = ApolloSchemaDownloadConfiguration.DownloadMethod.RegistrySettings(apiKey: <#Replace Me For Testing#>,
  //                                                                                         graphID: "Apollo-Fullstack-8zo5jl")
  //
  //let configuration = ApolloSchemaDownloadConfiguration(using: .registry(registrySettings),
  //                                                      outputFolderURL: output)

  do {
    try ApolloSchemaDownloader.fetch(configuration: configuration)
  } catch {
    print(error)
    continue
  }

}

extension Target {

  var serverEndpoint: URL? {
    switch self {
    case .upload:
      return URL(string: "http://localhost:4000/")!
    case .starWars:
      return URL(string: "http://localhost:8080/graphql")!
//    case .gitHub:
//      return nil
    case .animalKingdom:
      return nil
    }
  }

}
