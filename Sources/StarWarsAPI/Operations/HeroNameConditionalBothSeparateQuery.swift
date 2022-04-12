// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroNameConditionalBothSeparateQuery: GraphQLQuery {
  public let operationName: String = "HeroNameConditionalBothSeparate"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroNameConditionalBothSeparate($skipName: Boolean!, $includeName: Boolean!) {
        hero {
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

  public var variables: Variables? {
    ["skipName": skipName,
     "includeName": includeName]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { data["hero"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      public var name: String { data["name"] }
    }
  }
}