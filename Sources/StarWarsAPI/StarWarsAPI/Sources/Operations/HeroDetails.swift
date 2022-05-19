// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct HeroDetails: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HeroDetails on Character {
      __typename
      name
      ... on Human {
        height
      }
      ... on Droid {
        primaryFunction
      }
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("name", String.self),
    .inlineFragment(AsHuman.self),
    .inlineFragment(AsDroid.self),
  ] }

  public var name: String { data["name"] }

  public var asHuman: AsHuman? { _asInlineFragment() }
  public var asDroid: AsDroid? { _asInlineFragment() }

  /// AsHuman
  public struct AsHuman: StarWarsAPI.InlineFragment {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
    public static var selections: [Selection] { [
      .field("height", Float?.self),
    ] }

    public var height: Float? { data["height"] }
    public var name: String { data["name"] }
  }

  /// AsDroid
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
    public static var selections: [Selection] { [
      .field("primaryFunction", String?.self),
    ] }

    public var primaryFunction: String? { data["primaryFunction"] }
    public var name: String { data["name"] }
  }
}