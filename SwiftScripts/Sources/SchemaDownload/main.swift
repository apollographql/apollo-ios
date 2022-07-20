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
    using: .introspection(endpointURL: endpoint, outputFormat: .SDL),
    outputPath: outputURL.path
  )

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
    case .upload: return URL(string: "http://localhost:4001/")!
    case .starWars: return URL(string: "http://localhost:8080/graphql")!
    case .subscription: return URL(string: "http://localhost:4000/graphql")!
    default: return nil
    }
  }

}
