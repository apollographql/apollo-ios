// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameAndAppearsInQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameAndAppearsIn"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "f714414a2002404f9943490c8cc9c1a7b8ecac3ca229fa5a326186b43c1385ce",
    definition: .init(
      #"""
      query HeroNameAndAppearsIn($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          appearsIn
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
    public init(_data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    public init(
      hero: Hero? = nil
    ) {
      let objectType = StarWarsAPI.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "hero": hero._fieldData
      ]))
    }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("name", String.self),
        .field("appearsIn", [GraphQLEnum<StarWarsAPI.Episode>?].self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }
      /// The movies this character appears in
      public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }

      public init(
        __typename: String,
        name: String,
        appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?]
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            StarWarsAPI.Interfaces.Character
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "name": name,
            "appearsIn": appearsIn
        ]))
      }
    }
  }
}
