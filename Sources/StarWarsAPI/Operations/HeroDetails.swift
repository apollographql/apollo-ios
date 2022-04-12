// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct HeroDetails: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HeroDetails on Character {
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
    .typeCase(AsHuman.self),
    .typeCase(AsDroid.self),
  ] }

  public var name: String { data["name"] }

  public var asHuman: AsHuman? { _asType() }
  public var asDroid: AsDroid? { _asType() }

  /// AsHuman
  public struct AsHuman: StarWarsAPI.TypeCase {
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
  public struct AsDroid: StarWarsAPI.TypeCase {
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