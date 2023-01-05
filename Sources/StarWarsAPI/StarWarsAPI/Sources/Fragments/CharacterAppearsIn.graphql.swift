// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterAppearsIn on Character {
      __typename
      appearsIn
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("appearsIn", [GraphQLEnum<Episode>?].self),
  ] }

  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
}
