//  This file was automatically generated and should not be edited.

import Apollo

public final class RepositoryQuery: GraphQLQuery {
  public static let operationString =
    "query Repository {\n  repository(owner: \"apollographql\", name: \"apollo-ios\") {\n    __typename\n    issueOrPullRequest(number: 13) {\n      __typename\n      ... on Issue {\n        body\n        ... on UniformResourceLocatable {\n          url\n        }\n        author {\n          __typename\n          avatarUrl\n        }\n      }\n      ... on Reactable {\n        viewerCanReact\n        ... on Comment {\n          author {\n            __typename\n            login\n          }\n        }\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("repository", arguments: ["owner": "apollographql", "name": "apollo-ios"], type: .object(Repository.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(repository: Repository? = nil) {
      self.init(snapshot: ["__typename": "Query", "repository": repository.flatMap { $0.snapshot }])
    }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? {
      get {
        return (snapshot["repository"] as! Snapshot?).flatMap { Repository(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "repository")
      }
    }

    public struct Repository: GraphQLSelectionSet {
      public static let possibleTypes = ["Repository"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("issueOrPullRequest", arguments: ["number": 13], type: .object(IssueOrPullRequest.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(issueOrPullRequest: IssueOrPullRequest? = nil) {
        self.init(snapshot: ["__typename": "Repository", "issueOrPullRequest": issueOrPullRequest.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Returns a single issue-like object from the current repository by number.
      public var issueOrPullRequest: IssueOrPullRequest? {
        get {
          return (snapshot["issueOrPullRequest"] as! Snapshot?).flatMap { IssueOrPullRequest(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "issueOrPullRequest")
        }
      }

      public struct IssueOrPullRequest: GraphQLSelectionSet {
        public static let possibleTypes = ["Issue", "PullRequest"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["Issue": AsIssue.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("viewerCanReact", type: .nonNull(.scalar(Bool.self))),
              GraphQLField("author", type: .object(Author.selections)),
            ]
          )
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public static func makePullRequest(viewerCanReact: Bool, author: Author? = nil) -> IssueOrPullRequest {
          return IssueOrPullRequest(snapshot: ["__typename": "PullRequest", "viewerCanReact": viewerCanReact, "author": author.flatMap { $0.snapshot }])
        }

        public static func makeIssue(body: String, url: String, author: AsIssue.Author? = nil, viewerCanReact: Bool) -> IssueOrPullRequest {
          return IssueOrPullRequest(snapshot: ["__typename": "Issue", "body": body, "url": url, "author": author.flatMap { $0.snapshot }, "viewerCanReact": viewerCanReact])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Can user react to this subject
        public var viewerCanReact: Bool {
          get {
            return snapshot["viewerCanReact"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "viewerCanReact")
          }
        }

        /// The actor who authored the comment.
        public var author: Author? {
          get {
            return (snapshot["author"] as! Snapshot?).flatMap { Author(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "author")
          }
        }

        public struct Author: GraphQLSelectionSet {
          public static let possibleTypes = ["Organization", "User", "Bot"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("login", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public static func makeOrganization(login: String) -> Author {
            return Author(snapshot: ["__typename": "Organization", "login": login])
          }

          public static func makeUser(login: String) -> Author {
            return Author(snapshot: ["__typename": "User", "login": login])
          }

          public static func makeBot(login: String) -> Author {
            return Author(snapshot: ["__typename": "Bot", "login": login])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The username of the actor.
          public var login: String {
            get {
              return snapshot["login"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "login")
            }
          }
        }

        public var asIssue: AsIssue? {
          get {
            if !AsIssue.possibleTypes.contains(__typename) { return nil }
            return AsIssue(snapshot: snapshot)
          }
          set {
            guard let newValue = newValue else { return }
            snapshot = newValue.snapshot
          }
        }

        public struct AsIssue: GraphQLSelectionSet {
          public static let possibleTypes = ["Issue"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("body", type: .nonNull(.scalar(String.self))),
            GraphQLField("url", type: .nonNull(.scalar(String.self))),
            GraphQLField("author", type: .object(Author.selections)),
            GraphQLField("viewerCanReact", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("author", type: .object(Author.selections)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(body: String, url: String, author: Author? = nil, viewerCanReact: Bool) {
            self.init(snapshot: ["__typename": "Issue", "body": body, "url": url, "author": author.flatMap { $0.snapshot }, "viewerCanReact": viewerCanReact])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Identifies the body of the issue.
          public var body: String {
            get {
              return snapshot["body"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "body")
            }
          }

          /// The HTTP URL for this issue
          public var url: String {
            get {
              return snapshot["url"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "url")
            }
          }

          /// The actor who authored the comment.
          public var author: Author? {
            get {
              return (snapshot["author"] as! Snapshot?).flatMap { Author(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "author")
            }
          }

          /// Can user react to this subject
          public var viewerCanReact: Bool {
            get {
              return snapshot["viewerCanReact"]! as! Bool
            }
            set {
              snapshot.updateValue(newValue, forKey: "viewerCanReact")
            }
          }

          public struct Author: GraphQLSelectionSet {
            public static let possibleTypes = ["Organization", "User", "Bot"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("avatarUrl", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("login", type: .nonNull(.scalar(String.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public static func makeOrganization(avatarUrl: String, login: String) -> Author {
              return Author(snapshot: ["__typename": "Organization", "avatarUrl": avatarUrl, "login": login])
            }

            public static func makeUser(avatarUrl: String, login: String) -> Author {
              return Author(snapshot: ["__typename": "User", "avatarUrl": avatarUrl, "login": login])
            }

            public static func makeBot(avatarUrl: String, login: String) -> Author {
              return Author(snapshot: ["__typename": "Bot", "avatarUrl": avatarUrl, "login": login])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A URL pointing to the actor's public avatar.
            public var avatarUrl: String {
              get {
                return snapshot["avatarUrl"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "avatarUrl")
              }
            }

            /// The username of the actor.
            public var login: String {
              get {
                return snapshot["login"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "login")
              }
            }
          }
        }
      }
    }
  }
}