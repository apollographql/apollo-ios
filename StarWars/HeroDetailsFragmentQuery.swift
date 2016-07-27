import Apollo

public class HeroDetailsFragmentQuery: GraphQLQuery {
  let episode: Episode?
  
  public init(episode: Episode? = nil) {
    self.episode = episode
  }
  
  public var operationDefinition =
    "query HeroDetailsFragmentQuery($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    ...HeroDetails" +
    "  }" +
    "}"
  
  public var queryDocument: String {
    return operationDefinition.appending(HeroDetailsFragment.fragmentDefinition)
  }
  
  public var variables: GraphQLMap? {
    guard let episode = episode else { return nil }
    return ["episode": episode]
  }
  
  public struct Data: GraphQLMapConvertible {
    public let hero: HeroDetails
    
    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero", possibleTypes: ["Human": Hero_Human.self, "Droid": Hero_Droid.self])
    }
    
    public struct Hero_Human: HeroDetails_Human, GraphQLMapConvertible {
      public let name: String
      public let homePlanet: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        homePlanet = try map.value(forKey: "homePlanet")
      }
    }
    
    public struct Hero_Droid: HeroDetails_Droid, GraphQLMapConvertible {
      public let name: String
      public let primaryFunction: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        primaryFunction = try map.value(forKey: "primaryFunction")
      }
    }
  }
}

public class HeroDetailsFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment HeroDetails on Character {" +
    "  __typename" +
    "  name" +
    "  ... on Human {" +
    "    homePlanet" +
    "  }" +
    "  ... on Droid {" +
    "    primaryFunction" +
    "  }" +
    "}"
  
  public typealias Data = HeroDetails
}

public protocol HeroDetails {
  var name: String { get }
}

public protocol HeroDetails_Human: HeroDetails {
  var homePlanet: String { get }
}

public protocol HeroDetails_Droid: HeroDetails {
  var primaryFunction: String { get }
}
