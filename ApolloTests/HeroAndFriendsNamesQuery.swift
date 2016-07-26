import Apollo

public class HeroAndFriendsNamesQuery: GraphQLQuery {
  public var queryString =
    "{" +
    "  hero {" +
    "    name" +
    "    friends {" +
    "      name" +
    "    }" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero
    
    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero")
    }
    
    public struct Hero: GraphQLMapConvertible {
      public let name: String
      public let friends: [Friend]
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        friends = try map.list(forKey: "friends")
      }
      
      public struct Friend: GraphQLMapConvertible {
        public let name: String
        
        public init(map: GraphQLMap) throws {
          name = try map.value(forKey: "name")
        }
      }
    }
  }
}
