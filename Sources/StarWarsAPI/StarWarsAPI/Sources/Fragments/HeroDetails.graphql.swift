// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct HeroDetails: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HeroDetails on Character {
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
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [Selection] { [
    .field("name", String.self),
    .inlineFragment(AsHuman.self),
    .inlineFragment(AsDroid.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }

  public var asHuman: AsHuman? { _asInlineFragment() }
  public var asDroid: AsDroid? { _asInlineFragment() }

  /// AsHuman
  ///
  /// Parent Type: `Human`
  public struct AsHuman: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Human }
    public static var __selections: [Selection] { [
      .field("height", Double?.self),
    ] }

    /// Height in the preferred unit, default is meters
    public var height: Double? { __data["height"] }
    /// The name of the character
    public var name: String { __data["name"] }
  }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Droid }
    public static var __selections: [Selection] { [
      .field("primaryFunction", String?.self),
    ] }

    /// This droid's primary function
    public var primaryFunction: String? { __data["primaryFunction"] }
    /// The name of the character
    public var name: String { __data["name"] }
  }
}
