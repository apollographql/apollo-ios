// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameConditionalBothSeparateQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameConditionalBothSeparate"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "d0f9e9205cdc09320035662f528a177654d3275b0bf94cf0e259a65fde33e7e5",
    definition: .init(
      """
      query HeroNameConditionalBothSeparate($skipName: Boolean!, $includeName: Boolean!) {
        hero {
          __typename
          name @skip(if: $skipName)
          name @include(if: $includeName)
        }
      }
      """
    ))

  public var skipName: Bool
  public var includeName: Bool

  public init(
    skipName: Bool,
    includeName: Bool
  ) {
    self.skipName = skipName
    self.includeName = includeName
  }

  public var __variables: Variables? { [
    "skipName": skipName,
    "includeName": includeName
  ] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [Selection] { [
        .include(if: !"skipName" || "includeName", .field("name", String.self)),
      ] }

      /// The name of the character
      public var name: String? { __data["name"] }
    }
  }
}
