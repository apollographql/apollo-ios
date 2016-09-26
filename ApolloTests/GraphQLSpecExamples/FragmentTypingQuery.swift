import Apollo

public class FragmentTypingQuery: GraphQLQuery {
  public static let operationDefinition =
    "query FragmentTyping {" +
    "  profiles(handles: [\"zuck\", \"cocacola\"]) {" +
    "    handle" +
    "    ...UserDetails" +
    "    ...PageDetails" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let profiles: [Profile]
    
    public init(map: GraphQLMap) throws {
      profiles = try map.list(forKey: "profiles", possibleTypes: ["User": Profile_User.self, "Page": Profile_Page.self])
    }
    
    public typealias Profile = FragmentTypingQuery_Profile
    
    public struct Profile_User: Profile, UserDetails, GraphQLMapConvertible {
      public let handle: String
      public let friends: UserDetails_Friends
      
      public init(map: GraphQLMap) throws {
        handle = try map.value(forKey: "handle")
        friends = try map.value(forKey: "friends")
      }
    }
    
    public struct Profile_Page: Profile, PageDetails, GraphQLMapConvertible {
      public let handle: String
      public let likers: PageDetails_Likers
      
      public init(map: GraphQLMap) throws {
        handle = try map.value(forKey: "handle")
        likers = try map.value(forKey: "likers")
      }
    }
  }
}

public protocol FragmentTypingQuery_Profile {
  var handle: String { get }
}

public class UserFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment userFragment on User {" +
    "  friends {" +
    "    count" +
    "  }" +
    "}"
  
   public typealias Data = UserDetails
}

public protocol UserDetails {
  var friends: UserDetails_Friends { get }
}

public struct UserDetails_Friends: GraphQLMapConvertible {
  public let count: Int
  
  public init(map: GraphQLMap) throws {
    count = try map.value(forKey: "count")
  }
}

public class PageFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment pageFragment on User {" +
    "  likers {" +
    "    count" +
    "  }" +
    "}"
  
  public typealias Data = PageDetails
}

public protocol PageDetails {
  var likers: PageDetails_Likers { get }
}

public struct PageDetails_Likers: GraphQLMapConvertible {
  public let count: Int
  
  public init(map: GraphQLMap) throws {
    count = try map.value(forKey: "count")
  }
}
