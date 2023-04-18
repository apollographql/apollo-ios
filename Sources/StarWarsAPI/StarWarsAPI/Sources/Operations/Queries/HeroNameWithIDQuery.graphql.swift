// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameWithIDQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameWithID"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "83c03f612c46fca72f6cb902df267c57bffc9209bc44dd87d2524fb2b34f6f18",
    definition: .init(
      #"""
      query HeroNameWithID($episode: Episode) {
        hero(episode: $episode) {
          __typename
          id
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
        .field("id", StarWarsAPI.ID.self),
        .field("name", String.self),
      ] }

      /// The ID of the character
      public var id: StarWarsAPI.ID { __data["id"] }
      /// The name of the character
      public var name: String { __data["name"] }

      public init(
        __typename: String,
        id: StarWarsAPI.ID,
        name: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "id": id,
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
