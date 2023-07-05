// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RepoURLQuery: GraphQLQuery {
  public static let operationName: String = "RepoURL"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"""
      query RepoURL {
        repository(owner: "apollographql", name: "apollo-ios") {
          __typename
          url
        }
      }
      """#
    ))

  public init() {}

  public struct Data: GitHubAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GitHubAPI.Objects.Repository }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("url", GitHubAPI.URI.self),
      ] }

      /// The HTTP URL for this repository
      public var url: GitHubAPI.URI { __data["url"] }
    }
  }
}
