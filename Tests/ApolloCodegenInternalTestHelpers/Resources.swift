import Foundation

private class BundleFinder {}

public struct Resources {
  static let Bundle = Foundation.Bundle.init(for: BundleFinder.self)
  static let url = Bundle.resourceURL!

  public enum AnimalKingdom {
    public static let Schema = Bundle.url(
      forResource: "AnimalSchema",
      withExtension: "graphqls",
      subdirectory: "animalkingdom-graphql"
    )!

    public static let GraphQLOperations: [URL] = Bundle.urls(
      forResourcesWithExtension: "graphql",
      subdirectory: "animalkingdom-graphql"
    )!

    public static let CCNGraphQLOperations: [URL] = Bundle.urls(
      forResourcesWithExtension: "graphql",
      subdirectory: "animalkingdom-graphql/ccnGraphql"
    )! +
    Bundle.urls(
      forResourcesWithExtension: "graphql",
      subdirectory: "animalkingdom-graphql"
    )!

    private static func GraphQLOperation(named name: String) -> URL {
      Resources.GraphQLOperation(named: name, subdirectory: "animalkingdom-graphql")
    }
  }

  private static func GraphQLOperation(
    named name: String,
    subdirectory: String
  ) -> URL {
    return Bundle.url(
      forResource: name,
      withExtension: "graphql",
      subdirectory: subdirectory
    )!
  }

  // Star Wars

  public enum StarWars {
    public static let JSONSchema = Bundle.url(
      forResource: "schema",
      withExtension: "json",
      subdirectory: "starwars-graphql"
    )!

    public static let GraphQLOperations: [URL] = Bundle.urls(
      forResourcesWithExtension: "graphql",
      subdirectory: "starwars-graphql"
    )!

    public static func GraphQLOperation(named name: String) -> URL {
      Resources.GraphQLOperation(named: name, subdirectory: "starwars-graphql")
    }
  }


}
