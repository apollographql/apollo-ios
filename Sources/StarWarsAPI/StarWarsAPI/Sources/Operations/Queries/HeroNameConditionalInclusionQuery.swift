// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "338081aea3acc83d04af0741ecf0da1ec2ee8e6468a88383476b681015905ef8",
    definition: .init(
      """
      query HeroNameConditionalInclusion($includeName: Boolean!) {
        hero {
          __typename
          name @include(if: $includeName)
        }
      }
      """
    ))

  public var includeName: Bool

  public init(includeName: Bool) {
    self.includeName = includeName
  }

  public var variables: Variables? {
    ["includeName": includeName]
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
        .include(if: "includeName", .field("name", String.self)),
      ] }

      public var name: String? { __data["name"] }
    }
  }
}