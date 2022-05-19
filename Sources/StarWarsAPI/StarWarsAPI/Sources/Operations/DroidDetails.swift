// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct DroidDetails: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidDetails on Droid {
      __typename
      name
      primaryFunction
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
  public static var selections: [Selection] { [
    .field("name", String.self),
    .field("primaryFunction", String?.self),
  ] }

  public var name: String { data["name"] }
  public var primaryFunction: String? { data["primaryFunction"] }
}