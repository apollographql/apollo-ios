import Apollo

public class TwoHeroesQuery: GraphQLQuery {
  public init() {}
  
  public let operationDefinition =
    "query TwoHeroes {" +
    "  r2: hero {" +
    "    name" +
    "  }" +
    "  luke: hero(episode: EMPIRE) {" +
    "    name" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let r2: R2
    public let luke: Luke
    
    public init(map: GraphQLMap) throws {
      r2 = try map.value(forKey: "r2")
      luke = try map.value(forKey: "luke")
    }
    
    public struct R2: GraphQLMapConvertible {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
    public struct Luke: GraphQLMapConvertible {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
  }
}
