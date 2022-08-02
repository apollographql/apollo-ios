// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroDetailsFragmentConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetailsFragmentConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "b0fa7927ff93b4a579c3460fb04d093072d34c8018e41197c7e080aeeec5e19b",
    definition: .init(
      """
      query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {
        hero {
          __typename
          ...HeroDetails @include(if: $includeDetails)
        }
      }
      """,
      fragments: [HeroDetails.self]
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

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
      public static var selections: [Selection] { [
        .include(if: "includeDetails", .fragment(HeroDetails.self)),
      ] }

      public var ifIncludeDetails: IfIncludeDetails? { _asInlineFragment(if: "includeDetails") }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var heroDetails: HeroDetails? { _toFragment(if: "includeDetails") }
      }

      /// Hero.IfIncludeDetails
      ///
      /// Parent Type: `Character`
      public struct IfIncludeDetails: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }

        /// The name of the character
        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var heroDetails: HeroDetails { _toFragment() }
        }
      }
    }
  }
}
