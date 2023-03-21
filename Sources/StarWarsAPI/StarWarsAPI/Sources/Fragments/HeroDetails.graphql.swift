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
    self.init(_dataDict: DataDict(data: [
        "__typename": objectType.typename,
        "name": name
      ]))
  }

  /// AsHuman
  ///
  /// Parent Type: `Human`
  public struct AsHuman: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = HeroDetails
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
      self.init(_dataDict: DataDict(data: [
          "__typename": objectType.typename,
          "height": height,
          "name": name
        ]))
    }
  }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = HeroDetails
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
      self.init(_dataDict: DataDict(data: [
          "__typename": objectType.typename,
          "primaryFunction": primaryFunction,
          "name": name
        ]))
    }
  }
}
