// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class IssuesAndCommentsForRepositoryQuery: GraphQLQuery {
  public static let operationName: String = "IssuesAndCommentsForRepository"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query IssuesAndCommentsForRepository {
        repository(name: "apollo-ios", owner: "apollographql") {
          __typename
          name
          issues(last: 100) {
            __typename
            nodes {
              __typename
              title
              author {
                __typename
                ...AuthorDetails
              }
              body
              comments(last: 100) {
                __typename
                nodes {
                  __typename
                  body
                  author {
                    __typename
                    ...AuthorDetails
                  }
                }
              }
            }
          }
        }
      }
      """#,
      fragments: [AuthorDetails.self]
    ))

  public init() {}

  public struct Data: GitHubAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("repository", Repository?.self, arguments: [
        "name": "apollo-ios",
        "owner": "apollographql"
      ]),
    ] }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? { __data["repository"] }

    /// Repository
    ///
    /// Parent Type: `Repository`
    public struct Repository: GitHubAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.Repository }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("issues", Issues.self, arguments: ["last": 100]),
      ] }

      /// The name of the repository.
      public var name: String { __data["name"] }
      /// A list of issues that have been opened in the repository.
      public var issues: Issues { __data["issues"] }

      /// Repository.Issues
      ///
      /// Parent Type: `IssueConnection`
      public struct Issues: GitHubAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.IssueConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Repository.Issues.Node
        ///
        /// Parent Type: `Issue`
        public struct Node: GitHubAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.Issue }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("title", String.self),
            .field("author", Author?.self),
            .field("body", String.self),
            .field("comments", Comments.self, arguments: ["last": 100]),
          ] }

          /// Identifies the issue title.
          public var title: String { __data["title"] }
          /// The actor who authored the comment.
          public var author: Author? { __data["author"] }
          /// Identifies the body of the issue.
          public var body: String { __data["body"] }
          /// A list of comments associated with the Issue.
          public var comments: Comments { __data["comments"] }

          /// Repository.Issues.Node.Author
          ///
          /// Parent Type: `Actor`
          public struct Author: GitHubAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Interfaces.Actor }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(AuthorDetails.self),
            ] }

            /// The username of the actor.
            public var login: String { __data["login"] }

            public var asUser: AsUser? { _asInlineFragment() }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var authorDetails: AuthorDetails { _toFragment() }
            }

            /// Repository.Issues.Node.Author.AsUser
            ///
            /// Parent Type: `User`
            public struct AsUser: GitHubAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = Repository.Issues.Node.Author
              public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.User }
              public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                AuthorDetails.self,
                Repository.Issues.Node.Author.self,
                AuthorDetails.AsUser.self
              ] }

              /// The username of the actor.
              public var login: String { __data["login"] }
              public var id: GitHubAPI.ID { __data["id"] }
              /// The user's public profile name.
              public var name: String? { __data["name"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var authorDetails: AuthorDetails { _toFragment() }
              }
            }
          }

          /// Repository.Issues.Node.Comments
          ///
          /// Parent Type: `IssueCommentConnection`
          public struct Comments: GitHubAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.IssueCommentConnection }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("nodes", [Node?]?.self),
            ] }

            /// A list of nodes.
            public var nodes: [Node?]? { __data["nodes"] }

            /// Repository.Issues.Node.Comments.Node
            ///
            /// Parent Type: `IssueComment`
            public struct Node: GitHubAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.IssueComment }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("body", String.self),
                .field("author", Author?.self),
              ] }

              /// The body as Markdown.
              public var body: String { __data["body"] }
              /// The actor who authored the comment.
              public var author: Author? { __data["author"] }

              /// Repository.Issues.Node.Comments.Node.Author
              ///
              /// Parent Type: `Actor`
              public struct Author: GitHubAPI.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Interfaces.Actor }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(AuthorDetails.self),
                ] }

                /// The username of the actor.
                public var login: String { __data["login"] }

                public var asUser: AsUser? { _asInlineFragment() }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var authorDetails: AuthorDetails { _toFragment() }
                }

                /// Repository.Issues.Node.Comments.Node.Author.AsUser
                ///
                /// Parent Type: `User`
                public struct AsUser: GitHubAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public typealias RootEntityType = Repository.Issues.Node.Comments.Node.Author
                  public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.User }
                  public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                    AuthorDetails.self,
                    Repository.Issues.Node.Comments.Node.Author.self,
                    AuthorDetails.AsUser.self
                  ] }

                  /// The username of the actor.
                  public var login: String { __data["login"] }
                  public var id: GitHubAPI.ID { __data["id"] }
                  /// The user's public profile name.
                  public var name: String? { __data["name"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public var authorDetails: AuthorDetails { _toFragment() }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
