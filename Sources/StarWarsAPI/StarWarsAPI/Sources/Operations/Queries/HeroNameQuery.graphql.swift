// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameQuery: GraphQLQuery {
  public static let operationName: String = "HeroName"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671",
    definition: .init(
      #"""
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
        }
      }
      """#
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var __variables: Variables? { ["episode": episode] }

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
        .field("name", String.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }

      public init(
        __typename: String,
        name: String
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
    }
  }
}
