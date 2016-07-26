import Apollo

public class FeedQuery: GraphQLQuery {
  public init() {
  }
  
  public var queryString =
    "{" +
    "  feed(type: TOP) {" +
    "    repository {" +
    "      full_name" +
    "      stargazers_count" +
    "    }" +
    "    score" +
    "    postedBy {" +
    "      login" +
    "      avatar_url" +
    "    }" +
    "  }" +
    "}"
  
  public struct Data: GraphQLMapConvertible {
    public let feed: [Entry]
    
    public init(map: GraphQLMap) throws {
      feed = try map.list(forKey: "feed")
    }
    
    public struct Entry: GraphQLMapConvertible {
      public let repository: Repository
      public let score: Int
      public let postedBy: PostedBy
      
      public init(map: GraphQLMap) throws {
        repository = try map.value(forKey: "repository")
        score = try map.value(forKey: "score")
        postedBy = try map.value(forKey: "postedBy")
      }
      
      public struct Repository: GraphQLMapConvertible {
        public let fullName: String
        public let stargazersCount: Int
        
        public init(map: GraphQLMap) throws {
          fullName = try map.value(forKey: "full_name")
          stargazersCount = try map.value(forKey: "stargazers_count")
        }
      }
      
      public struct PostedBy: GraphQLMapConvertible {
        public let login: String
        public let avatarURL: URL
        
        public init(map: GraphQLMap) throws {
          login = try map.value(forKey: "login")
          avatarURL = try map.value(forKey: "avatar_url")
        }
      }
    }
  }
}
