// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroDetailsInlineConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetailsInlineConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "3091d9d3f1d2374e2f835ce05d332e50b3fe61502d73213b9aa511f0f94f091c",
    definition: .init(
      """
      query HeroDetailsInlineConditionalInclusion($includeDetails: Boolean!) {
        hero {
          __typename
          ... @include(if: $includeDetails) {
            __typename
            name
            appearsIn
          }
        }
      }
      """
    ))

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var variables: Variables? {
    ["includeDetails": includeDetails]
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
        .include(if: "includeDetails", .inlineFragment(IfIncludeDetails.self)),
      ] }

      public var ifIncludeDetails: IfIncludeDetails? { _asInlineFragment(if: "includeDetails") }

      /// Hero.IfIncludeDetails
      public struct IfIncludeDetails: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .field("name", String.self),
          .field("appearsIn", [GraphQLEnum<Episode>?].self),
        ] }

        public var name: String { __data["name"] }
        public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
      }
    }
  }
}