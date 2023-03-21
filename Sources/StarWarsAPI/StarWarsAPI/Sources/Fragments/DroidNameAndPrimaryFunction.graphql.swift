// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DroidNameAndPrimaryFunction: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidNameAndPrimaryFunction on Droid {
      __typename
      ...CharacterName
      ...DroidPrimaryFunction
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
  public static var __selections: [ApolloAPI.Selection] { [
    .fragment(CharacterName.self),
    .fragment(DroidPrimaryFunction.self),
  ] }

  /// This droid's primary function
  public var primaryFunction: String? { __data["primaryFunction"] }
  /// The name of the character
  public var name: String { __data["name"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public var characterName: CharacterName { _toFragment() }
    public var droidPrimaryFunction: DroidPrimaryFunction { _toFragment() }
  }

  public init(
    primaryFunction: String? = nil,
    name: String
  ) {
    let objectType = StarWarsAPI.Objects.Droid
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "primaryFunction": primaryFunction,
        "name": name
    ]))
  }
}
