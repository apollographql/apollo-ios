import Foundation

private class BundleFinder {}

public struct Resources {
  static let Bundle = Foundation.Bundle.init(for: BundleFinder.self)

  public static let GraphQLOperations: [URL] = Bundle.urls(
    forResourcesWithExtension: "graphql",
    subdirectory: nil
  )!

  public static let Schema = Bundle.url(
    forResource: "AnimalSchema",
    withExtension: "graphqls"
  )!
}
