// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct Dog: GraphQLSchemaName.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment Dog on Dog {
      __typename
      species
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { GraphQLSchemaName.Objects.Dog }
  public static var selections: [Selection] { [
    .field("species", String.self),
  ] }

  public var species: String { __data["species"] }
}
