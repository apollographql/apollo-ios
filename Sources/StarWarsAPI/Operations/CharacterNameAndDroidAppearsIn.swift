// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CharacterNameAndDroidAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndDroidAppearsIn on Character {
      name
      ... on Droid {
        appearsIn
      }
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("name", String.self),
    .typeCase(AsDroid.self),
  ] }

  public var name: String { data["name"] }

  public var asDroid: AsDroid? { _asType() }

  /// AsDroid
  public struct AsDroid: StarWarsAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
    public static var selections: [Selection] { [
      .field("appearsIn", [GraphQLEnum<Episode>?].self),
    ] }

    public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }
    public var name: String { data["name"] }
  }
}