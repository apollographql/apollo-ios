// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameConditionalExclusion"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroNameConditionalExclusion($skipName: Boolean!) {
        hero {
          __typename
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
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .include(if: !"skipName", .field("name", String.self)),
      ] }

      public var name: String? { __data["name"] }
    }
  }
}