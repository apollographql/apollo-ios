// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public let operationName: String = "HeroNameConditionalExclusion"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroNameConditionalExclusion($skipName: Boolean!) {
        hero {
          name @skip(if: $skipName)
        }
      }
      """
    ))

  public var skipName: Bool

  public init(skipName: Bool) {
    self.skipName = skipName
  }

  public var variables: Variables? {
    ["skipName": skipName]
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