// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RepoURLQuery: GraphQLQuery {
  public static let operationName: String = "RepoURL"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      """
      query RepoURL {
        repository(owner: "apollographql", name: "apollo-ios") {
          __typename
          url
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
        .field("url", URI.self),
      ] }

      /// The HTTP URL for this repository
      public var url: URI { __data["url"] }
    }
  }
}
