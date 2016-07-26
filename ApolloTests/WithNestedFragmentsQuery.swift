import Apollo

public class WithNestedFragmentsQuery: GraphQLQuery {
  public let queryString =
    "query withFragments {" +
    "  user(id: 4) {" +
    "    friends(first: 10) {" +
    "      ...friend" +
    "    }" +
    "    mutualFriends(first: 10) {" +
    "      ...friend" +
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
      public let mutualFriends: [Friend]
      
      public init(map: GraphQLMap) throws {
        friends = try map.list(forKey: "friends")
        mutualFriends = try map.list(forKey: "mutualFriends")
      }
      
      public struct Friend: FriendFragment.Data, GraphQLMapConvertible {
        public let id: String
        public let name: String
        public let profilePic: URL
        
        public init(map: GraphQLMap) throws {
          id = try map.value(forKey: "id")
          name = try map.value(forKey: "name")
          profilePic = try map.value(forKey: "profilePic")
        }
      }
      
      public struct MutualFriend: FriendFragment.Data, GraphQLMapConvertible {
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

private class FriendFragment: GraphQLFragment {
  let fragmentString =
    "{" +
    "  fragment friend on User {" +
    "      id" +
    "      name" +
    "      ...standardProfilePic" +
    "  }" +
    "}"
  
  typealias Data = Friend
}

private protocol Friend: StandardProfilePic {
  var id: String { get }
  var name: String { get }
}

private class StandardProfilePicFragment: GraphQLFragment {
  let fragmentString =
    "{" +
    "  fragment standardProfilePic on User {" +
    "      profilePic(size: 50)" +
    "  }" +
    "}"
  
  typealias Data = StandardProfilePic
}

private protocol StandardProfilePic {
  var profilePic: URL { get }
}
