import Apollo

public class HeroAndFriendsDetailsQuery: GraphQLQuery {
  let episode: Episode?
  
  public init(episode: Episode? = nil) {
    self.episode = episode
  }
  
  public var operationDefinition =
    "query HeroAndFriendsDetails($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    ...HeroDetails" +
    "    friends {" +
    "      ...HeroDetails" +
    "    }" +
    "  }" +
    "}"
  
  public var queryDocument: String {
    return operationDefinition.appending(HeroDetailsFragment.fragmentDefinition)
  }
  
  public var variables: GraphQLMap? {
    return ["episode": episode]
  }
  
  public typealias Hero = HeroAndFriendsDetailsQuery_Hero
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero
    
    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero", possibleTypes: ["Human": Hero_Human.self, "Droid": Hero_Droid.self])
    }
    
    public struct Hero_Human: HeroAndFriendsDetailsQuery_Hero, HeroDetails_Human, GraphQLMapConvertible {
      public let name: String
      public let appearsIn: [Episode]?
      public let friends: [Hero]?
      public let homePlanet: String?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        appearsIn = try map.list(forKey: "appearsIn")
        friends = try map.list(forKey: "friends", possibleTypes: ["Human": Hero_Human.self, "Droid": Hero_Droid.self])
        homePlanet = try map.value(forKey: "homePlanet")
      }
    }
    
    public struct Hero_Droid: HeroAndFriendsDetailsQuery_Hero, HeroDetails_Droid, GraphQLMapConvertible {
      public let name: String
      public let appearsIn: [Episode]?
      public let friends: [Hero]?
      public let primaryFunction: String?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        appearsIn = try map.list(forKey: "appearsIn")
        friends = try map.list(forKey: "friends", possibleTypes: ["Human": Hero_Human.self, "Droid": Hero_Droid.self])
        primaryFunction = try map.value(forKey: "primaryFunction")
      }
    }
  }
}

public protocol HeroAndFriendsDetailsQuery_Hero: HeroDetails {
  var friends: [HeroAndFriendsDetailsQuery_Hero]? { get }
}
