// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class RepositoryQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    "query Repository { repository(owner: \"apollographql\", name: \"apollo-ios\") { __typename issueOrPullRequest(number: 13) { __typename ... on Issue { body ... on UniformResourceLocatable { url } author { __typename avatarUrl } } ... on Reactable { viewerCanReact ... on Comment { author { __typename login } } } } } }"

  public let operationName: String = "Repository"

  public let operationIdentifier: String? = "63e25c339275a65f43b847e692e42caed8c06e25fbfb3dc8db6d4897b180c9ef"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("repository", arguments: ["owner": "apollographql", "name": "apollo-ios"], type: .object(Repository.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(repository: Repository? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "repository": repository.flatMap { (value: Repository) -> ResultMap in value.resultMap }])
    }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? {
      get {
        return (resultMap["repository"] as? ResultMap).flatMap { Repository(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "repository")
      }
    }

    public struct Repository: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Repository"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("issueOrPullRequest", arguments: ["number": 13], type: .object(IssueOrPullRequest.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(issueOrPullRequest: IssueOrPullRequest? = nil) {
        self.init(unsafeResultMap: ["__typename": "Repository", "issueOrPullRequest": issueOrPullRequest.flatMap { (value: IssueOrPullRequest) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Returns a single issue-like object from the current repository by number.
      public var issueOrPullRequest: IssueOrPullRequest? {
        get {
          return (resultMap["issueOrPullRequest"] as? ResultMap).flatMap { IssueOrPullRequest(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "issueOrPullRequest")
        }
      }

      public struct IssueOrPullRequest: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Issue", "PullRequest"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Issue": AsIssue.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("viewerCanReact", type: .nonNull(.scalar(Bool.self))),
                GraphQLField("author", type: .object(Author.selections)),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makePullRequest(viewerCanReact: Bool, author: Author? = nil) -> IssueOrPullRequest {
          return IssueOrPullRequest(unsafeResultMap: ["__typename": "PullRequest", "viewerCanReact": viewerCanReact, "author": author.flatMap { (value: Author) -> ResultMap in value.resultMap }])
        }

        public static func makeIssue(body: String, url: String, author: AsIssue.Author? = nil, viewerCanReact: Bool) -> IssueOrPullRequest {
          return IssueOrPullRequest(unsafeResultMap: ["__typename": "Issue", "body": body, "url": url, "author": author.flatMap { (value: AsIssue.Author) -> ResultMap in value.resultMap }, "viewerCanReact": viewerCanReact])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Can user react to this subject
        public var viewerCanReact: Bool {
          get {
            return resultMap["viewerCanReact"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "viewerCanReact")
          }
        }

        /// The actor who authored the comment.
        public var author: Author? {
          get {
            return (resultMap["author"] as? ResultMap).flatMap { Author(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "author")
          }
        }

        public struct Author: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Organization", "User", "Bot"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("login", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeOrganization(login: String) -> Author {
            return Author(unsafeResultMap: ["__typename": "Organization", "login": login])
          }

          public static func makeUser(login: String) -> Author {
            return Author(unsafeResultMap: ["__typename": "User", "login": login])
          }

          public static func makeBot(login: String) -> Author {
            return Author(unsafeResultMap: ["__typename": "Bot", "login": login])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The username of the actor.
          public var login: String {
            get {
              return resultMap["login"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "login")
            }
          }
        }

        public var asIssue: AsIssue? {
          get {
            if !AsIssue.possibleTypes.contains(__typename) { return nil }
            return AsIssue(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsIssue: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Issue"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("body", type: .nonNull(.scalar(String.self))),
              GraphQLField("url", type: .nonNull(.scalar(String.self))),
              GraphQLField("author", type: .object(Author.selections)),
              GraphQLField("viewerCanReact", type: .nonNull(.scalar(Bool.self))),
              GraphQLField("author", type: .object(Author.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(body: String, url: String, author: Author? = nil, viewerCanReact: Bool) {
            self.init(unsafeResultMap: ["__typename": "Issue", "body": body, "url": url, "author": author.flatMap { (value: Author) -> ResultMap in value.resultMap }, "viewerCanReact": viewerCanReact])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Identifies the body of the issue.
          public var body: String {
            get {
              return resultMap["body"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "body")
            }
          }

          /// The HTTP URL for this issue
          public var url: String {
            get {
              return resultMap["url"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "url")
            }
          }

          /// The actor who authored the comment.
          public var author: Author? {
            get {
              return (resultMap["author"] as? ResultMap).flatMap { Author(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "author")
            }
          }

          /// Can user react to this subject
          public var viewerCanReact: Bool {
            get {
              return resultMap["viewerCanReact"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "viewerCanReact")
            }
          }

          public struct Author: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Organization", "User", "Bot"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("avatarUrl", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("login", type: .nonNull(.scalar(String.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeOrganization(avatarUrl: String, login: String) -> Author {
              return Author(unsafeResultMap: ["__typename": "Organization", "avatarUrl": avatarUrl, "login": login])
            }

            public static func makeUser(avatarUrl: String, login: String) -> Author {
              return Author(unsafeResultMap: ["__typename": "User", "avatarUrl": avatarUrl, "login": login])
            }

            public static func makeBot(avatarUrl: String, login: String) -> Author {
              return Author(unsafeResultMap: ["__typename": "Bot", "avatarUrl": avatarUrl, "login": login])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A URL pointing to the actor's public avatar.
            public var avatarUrl: String {
              get {
                return resultMap["avatarUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "avatarUrl")
              }
            }

            /// The username of the actor.
            public var login: String {
              get {
                return resultMap["login"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "login")
              }
            }
          }
        }
      }
    }
  }
}

public final class RepoUrlQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    "query RepoURL { repository(owner: \"apollographql\", name: \"apollo-ios\") { __typename url } }"

  public let operationName: String = "RepoURL"

  public let operationIdentifier: String? = "b55f22bcbfaea0d861089b3fbe06299675a21d11ba7138ace39ecbde606a3dc1"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("repository", arguments: ["owner": "apollographql", "name": "apollo-ios"], type: .object(Repository.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(repository: Repository? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "repository": repository.flatMap { (value: Repository) -> ResultMap in value.resultMap }])
    }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? {
      get {
        return (resultMap["repository"] as? ResultMap).flatMap { Repository(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "repository")
      }
    }

    public struct Repository: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Repository"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String) {
        self.init(unsafeResultMap: ["__typename": "Repository", "url": url])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The HTTP URL for this repository
      public var url: String {
        get {
          return resultMap["url"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "url")
        }
      }
    }
  }
}
