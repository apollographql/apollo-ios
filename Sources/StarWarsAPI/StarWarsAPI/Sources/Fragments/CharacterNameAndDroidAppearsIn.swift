// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameAndDroidAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndDroidAppearsIn on Character {
      __typename
      name
      ... on Droid {
        __typename
        appearsIn
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
  public static var selections: [Selection] { [
    .field("name", String.self),
    .inlineFragment(AsDroid.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }

  public var asDroid: AsDroid? { _asInlineFragment() }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid) }
    public static var selections: [Selection] { [
      .field("appearsIn", [GraphQLEnum<Episode>?].self),
    ] }

    /// The movies this droid appears in
    public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
    /// The name of the character
    public var name: String { __data["name"] }
  }
}
