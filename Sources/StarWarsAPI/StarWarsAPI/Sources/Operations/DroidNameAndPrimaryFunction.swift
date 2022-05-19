// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct DroidNameAndPrimaryFunction: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidNameAndPrimaryFunction on Droid {
      __typename
      ...CharacterName
      ...DroidPrimaryFunction
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
  public static var selections: [Selection] { [
    .fragment(CharacterName.self),
    .fragment(DroidPrimaryFunction.self),
  ] }

  public var primaryFunction: String? { data["primaryFunction"] }
  public var name: String { data["name"] }

  public struct Fragments: FragmentContainer {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public var characterName: CharacterName { _toFragment() }
    public var droidPrimaryFunction: DroidPrimaryFunction { _toFragment() }
  }
}