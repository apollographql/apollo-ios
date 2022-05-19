// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLNullable

public struct DroidPrimaryFunction: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidPrimaryFunction on Droid {
      __typename
      primaryFunction
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
  public static var selections: [Selection] { [
    .field("primaryFunction", String?.self),
  ] }

  public var primaryFunction: String? { data["primaryFunction"] }
}