import Foundation

private class BundleFinder {}

public struct Resources {
  static let Bundle = Foundation.Bundle.init(for: BundleFinder.self)
  static let url = Bundle.resourceURL!

  public static let GraphQLOperations: [URL] = Bundle.urls(
    forResourcesWithExtension: "graphql",
    subdirectory: "graphql"
  )!

  public static let AnimalKingdomSchema = Bundle.url(
    forResource: "AnimalSchema",
    withExtension: "graphqls",
    subdirectory: "graphql"
  )!

  public static let CCNGraphQLOperations: [URL] = Bundle.urls(
    forResourcesWithExtension: "graphql",
    subdirectory: "graphql/ccnGraphql"
  )! +
  Bundle.urls(
    forResourcesWithExtension: "graphql",
    subdirectory: "graphql"
  )!
}
