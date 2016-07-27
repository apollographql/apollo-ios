import Apollo

public class HeroDetailsQuery: GraphQLQuery {
  let episode: Episode?
  
  public init(episode: Episode? = nil) {
    self.episode = episode
  }
  
  public var operationDefinition =
    "query HeroDetailsQuery($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "    ... on Human {" +
    "      homePlanet" +
    "    }" +
    "    ... on Droid {" +
    "      primaryFunction" +
    "    }" +
    "  }" +
    "}"
  
  public var variables: GraphQLMap? {
    guard let episode = episode else { return nil }
    return ["episode": episode]
  }
  
  public typealias Hero = HeroDetailsQuery_Hero
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero
    
    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero", possibleTypes: ["Human": Human.self, "Droid": Droid.self])
    }
    
    public struct Human: Hero, GraphQLMapConvertible {
      public var name: String
      public var homePlanet: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        homePlanet = try map.value(forKey: "homePlanet")
      }
    }
    
    public struct Droid: Hero, GraphQLMapConvertible {
      public let name: String
      public let primaryFunction: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        primaryFunction = try map.value(forKey: "primaryFunction")
      }
    }
  }
}

public protocol HeroDetailsQuery_Hero {
  var name: String { get }
}
