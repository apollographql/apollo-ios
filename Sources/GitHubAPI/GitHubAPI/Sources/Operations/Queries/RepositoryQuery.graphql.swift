// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class RepositoryQuery: GraphQLQuery {
  public static let operationName: String = "Repository"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query Repository {
        repository(owner: "apollographql", name: "apollo-ios") {
          __typename
          issueOrPullRequest(number: 13) {
            __typename
            ... on Issue {
              __typename
              body
              ... on UniformResourceLocatable {
                __typename
                url
              }
              author {
                __typename
                avatarUrl
              }
            }
            ... on Reactable {
              __typename
              viewerCanReact
              ... on Comment {
                __typename
                author {
                  __typename
                  login
                }
              }
            }
          }
        }
      }
      """
    ))

  public init() {}

  public struct Data: GitHubAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { GitHubAPI.Objects.Query }
    public static var __selections: [Selection] { [
      .field("repository", Repository?.self, arguments: [
        "owner": "apollographql",
        "name": "apollo-ios"
      ]),
    ] }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? { __data["repository"] }

    /// Repository
    ///
    /// Parent Type: `Repository`
    public struct Repository: GitHubAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { GitHubAPI.Objects.Repository }
      public static var __selections: [Selection] { [
        .field("issueOrPullRequest", IssueOrPullRequest?.self, arguments: ["number": 13]),
      ] }

      /// Returns a single issue-like object from the current repository by number.
      public var issueOrPullRequest: IssueOrPullRequest? { __data["issueOrPullRequest"] }

      /// Repository.IssueOrPullRequest
      ///
      /// Parent Type: `IssueOrPullRequest`
      public struct IssueOrPullRequest: GitHubAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GitHubAPI.Unions.IssueOrPullRequest }
        public static var __selections: [Selection] { [
          .inlineFragment(AsIssue.self),
          .inlineFragment(AsReactable.self),
        ] }

        public var asIssue: AsIssue? { _asInlineFragment() }
        public var asReactable: AsReactable? { _asInlineFragment() }

        /// Repository.IssueOrPullRequest.AsIssue
        ///
        /// Parent Type: `Issue`
        public struct AsIssue: GitHubAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GitHubAPI.Objects.Issue }
          public static var __selections: [Selection] { [
            .field("body", String.self),
            .field("url", URI.self),
            .field("author", Author?.self),
          ] }

          /// Identifies the body of the issue.
          public var body: String { __data["body"] }
          /// The URL to this resource.
          public var url: URI { __data["url"] }
          /// The actor who authored the comment.
          public var author: Author? { __data["author"] }
          /// Can user react to this subject
          public var viewerCanReact: Bool { __data["viewerCanReact"] }

          /// Repository.IssueOrPullRequest.AsIssue.Author
          ///
          /// Parent Type: `Actor`
          public struct Author: GitHubAPI.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { GitHubAPI.Interfaces.Actor }
            public static var __selections: [Selection] { [
              .field("avatarUrl", URI.self),
            ] }

            /// A URL pointing to the actor's public avatar.
            public var avatarUrl: URI { __data["avatarUrl"] }
            /// The username of the actor.
            public var login: String { __data["login"] }
          }
        }

        /// Repository.IssueOrPullRequest.AsReactable
        ///
        /// Parent Type: `Reactable`
        public struct AsReactable: GitHubAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GitHubAPI.Interfaces.Reactable }
          public static var __selections: [Selection] { [
            .field("viewerCanReact", Bool.self),
            .inlineFragment(AsComment.self),
          ] }

          /// Can user react to this subject
          public var viewerCanReact: Bool { __data["viewerCanReact"] }

          public var asComment: AsComment? { _asInlineFragment() }

          /// Repository.IssueOrPullRequest.AsReactable.AsComment
          ///
          /// Parent Type: `Comment`
          public struct AsComment: GitHubAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { GitHubAPI.Interfaces.Comment }
            public static var __selections: [Selection] { [
              .field("author", Author?.self),
            ] }

            /// The actor who authored the comment.
            public var author: Author? { __data["author"] }
            /// Can user react to this subject
            public var viewerCanReact: Bool { __data["viewerCanReact"] }

            /// Repository.IssueOrPullRequest.AsReactable.AsComment.Author
            ///
            /// Parent Type: `Actor`
            public struct Author: GitHubAPI.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: ParentType { GitHubAPI.Interfaces.Actor }
              public static var __selections: [Selection] { [
                .field("login", String.self),
              ] }

              /// The username of the actor.
              public var login: String { __data["login"] }
            }
          }
        }
      }
    }
  }
}
