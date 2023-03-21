// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroDetailsQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetails"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "207d29944f5822bff08a07db4a55274ea14035bacfe20699da41a47454f1181e",
    definition: .init(
      #"""
      query HeroDetails($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          ... on Human {
            __typename
            height
          }
          ... on Droid {
            __typename
            primaryFunction
          }
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
      let objectType = StarWarsAPI.Objects.Query
      self.init(_dataDict: DataDict(
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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("name", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      public init(
        __typename: String,
        name: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            StarWarsAPI.Interfaces.Character
        ])
        self.init(_dataDict: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "name": name
        ]))
      }

      /// Hero.AsHuman
      ///
      /// Parent Type: `Human`
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("height", Double?.self),
        ] }

        /// Height in the preferred unit, default is meters
        public var height: Double? { __data["height"] }
        /// The name of the character
        public var name: String { __data["name"] }

        public init(
          height: Double? = nil,
          name: String
        ) {
          let objectType = StarWarsAPI.Objects.Human
          self.init(_dataDict: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "height": height,
              "name": name
          ]))
        }
      }

      /// Hero.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("primaryFunction", String?.self),
        ] }

        /// This droid's primary function
        public var primaryFunction: String? { __data["primaryFunction"] }
        /// The name of the character
        public var name: String { __data["name"] }

        public init(
          primaryFunction: String? = nil,
          name: String
        ) {
          let objectType = StarWarsAPI.Objects.Droid
          self.init(_dataDict: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "primaryFunction": primaryFunction,
              "name": name
          ]))
        }
      }
    }
  }
}
