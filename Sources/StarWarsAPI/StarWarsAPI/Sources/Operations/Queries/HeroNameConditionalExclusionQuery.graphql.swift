// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameConditionalExclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "3dd42259adf2d0598e89e0279bee2c128a7913f02b1da6aa43f3b5def6a8a1f8",
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

  public var __variables: Variables? { ["skipName": skipName] }

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
        .include(if: !"skipName", .field("name", String.self)),
      ] }

      /// The name of the character
      public var name: String? { __data["name"] }
    }
  }
}
