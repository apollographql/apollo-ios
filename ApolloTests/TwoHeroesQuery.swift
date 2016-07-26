import Apollo

public class TwoHeroesQuery: GraphQLQuery {
  public var operationDefinition =
    "{" +
    "  r2: hero {" +
    "    name" +
    "  }" +
    "  luke: hero(episode: EMPIRE) {" +
    "    name" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let r2: Hero
    public let luke: Hero
    
    public init(map: GraphQLMap) throws {
      r2 = try map.value(forKey: "r2")
      luke = try map.value(forKey: "luke")
    }
    
    public struct Hero: GraphQLMapConvertible {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
  }
}
