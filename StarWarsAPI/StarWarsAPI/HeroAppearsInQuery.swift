import Apollo

public class HeroAppearsInQuery: GraphQLQuery {
  public init() {
  }
  
  public var operationDefinition =
    "{" +
    "  hero {" +
    "    name" +
    "    appearsIn" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero
    
    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero")
    }
    
    public struct Hero: GraphQLMapConvertible {
      public let name: String
      public let appearsIn: [Episode]
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        appearsIn = try map.list(forKey: "appearsIn")
      }
    }
  }
}
