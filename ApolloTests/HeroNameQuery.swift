import Apollo

public class HeroNameQuery: GraphQLQuery {
  public var operationDefinition =
    "{" +
    "  hero {" +
    "    name" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero
    
    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero")
    }
    
    public struct Hero: GraphQLMapConvertible {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
  }
}
