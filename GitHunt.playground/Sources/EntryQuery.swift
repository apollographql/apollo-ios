import Apollo

public class EntryQuery: GraphQLQuery {
  let repoFullName: String
  
  public init(repoFullName: String) {
    self.repoFullName = repoFullName
  }
  
  public var queryString =
    "query EntryQuery($repoFullName: String!) {" +
    "  entry(repoFullName: $repoFullName) {" +
    "    repository {" +
    "      full_name" +
    "      description" +
    "      stargazers_count" +
    "    }" +
    "    score" +
    "    postedBy {" +
    "      login" +
    "      avatar_url" +
    "    }" +
    "  }" +
    "}"
  
  public var variables: GraphQLMap? {
    return ["repoFullName": repoFullName]
  }
  
  public struct Data: GraphQLMapConvertible {
    public let entry: Entry
    
    public init(map: GraphQLMap) throws {
      entry = try map.value(forKey: "entry")
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
        public let description: String
        public let stargazersCount: Int
        
        public init(map: GraphQLMap) throws {
          fullName = try map.value(forKey: "full_name")
          description = try map.value(forKey: "description")
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
