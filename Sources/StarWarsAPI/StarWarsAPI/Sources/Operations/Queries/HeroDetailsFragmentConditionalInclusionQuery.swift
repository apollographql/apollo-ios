// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroDetailsFragmentConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetailsFragmentConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "b31aec7d977249e185922e4cc90318fd2c7197631470904bf937b0626de54b4f",
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
        .include(if: "includeDetails", .fragment(HeroDetails.self)),
      ] }

      public var ifIncludeDetails: IfIncludeDetails? { _asInlineFragment(if: "includeDetails") }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var heroDetails: HeroDetails? { _toFragment(if: "includeDetails") }
      }

      /// Hero.IfIncludeDetails
      public struct IfIncludeDetails: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }

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