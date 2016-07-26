import Apollo

public class NoFragmentsQuery: GraphQLQuery {
  public var queryString =
    "query noFragments {" +
    "  user(id: 4) {" +
    "    friends(first: 10) {" +
    "      id" +
    "      name" +
    "      profilePic(size: 50)" +
    "    }" +
    "    mutualFriends(first: 10) {" +
    "      id" +
    "      name" +
    "      profilePic(size: 50)" +
    "    }" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let user: User
    
    public init(map: GraphQLMap) throws {
      user = try map.value(forKey: "user")
    }
    
    public struct User: GraphQLMapConvertible {
      public let friends: [Friend]
      public let mutualFriends: [MutualFriend]
      
      public init(map: GraphQLMap) throws {
        friends = try map.list(forKey: "friends")
        mutualFriends = try map.list(forKey: "mutualFriends")
      }
      
      public struct Friend: GraphQLMapConvertible {
        public let id: String
        public let name: String
        public let profilePic: URL
        
        public init(map: GraphQLMap) throws {
          id = try map.value(forKey: "id")
          name = try map.value(forKey: "name")
          profilePic = try map.value(forKey: "profilePic")
        }
      }
      
      public struct MutualFriend: GraphQLMapConvertible {
        public let id: String
        public let name: String
        public let profilePic: URL
        
        public init(map: GraphQLMap) throws {
          id = try map.value(forKey: "id")
          name = try map.value(forKey: "name")
          profilePic = try map.value(forKey: "profilePic")
        }
      }
    }
  }
}
