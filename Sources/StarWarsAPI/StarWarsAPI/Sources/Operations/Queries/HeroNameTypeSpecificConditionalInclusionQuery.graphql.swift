// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameTypeSpecificConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameTypeSpecificConditionalInclusion"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "76aecc75265295818d3990000b17e32d5524ca85a4bc159ae8a3f8ec7ce91cc3",
    definition: .init(
      #"""
      query HeroNameTypeSpecificConditionalInclusion($episode: Episode, $includeName: Boolean!) {
        hero(episode: $episode) {
          __typename
          name @include(if: $includeName)
          ... on Droid {
            __typename
            name
          }
        }
      }
      """#
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>
  public var includeName: Bool

  public init(
    episode: GraphQLNullable<GraphQLEnum<Episode>>,
    includeName: Bool
  ) {
    self.episode = episode
    self.includeName = includeName
  }

  public var __variables: Variables? { [
    "episode": episode,
    "includeName": includeName
  ] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    public init(
      hero: Hero? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Query.typename,
          "hero": hero._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(Self.self)
        ]
      ))
    }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsDroid.self),
        .include(if: "includeName", .field("name", String.self)),
      ] }

      /// The name of the character
      public var name: String? { __data["name"] }

      public var asDroid: AsDroid? { _asInlineFragment() }

      public init(
        __typename: String,
        name: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "name": name,
          ],
          fulfilledFragments: [
            ObjectIdentifier(Self.self)
          ]
        ))
      }

      /// Hero.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = HeroNameTypeSpecificConditionalInclusionQuery.Data.Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("name", String.self),
        ] }

        /// What others call this droid
        public var name: String { __data["name"] }

        public init(
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": StarWarsAPI.Objects.Droid.typename,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(Self.self),
              ObjectIdentifier(Hero.self)
            ]
          ))
        }
      }
    }
  }
}
