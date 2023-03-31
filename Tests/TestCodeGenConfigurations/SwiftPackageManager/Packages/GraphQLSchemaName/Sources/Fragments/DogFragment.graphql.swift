// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DogFragment: GraphQLSchemaName.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DogFragment on Dog {
      __typename
      species
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Objects.Dog }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("species", String.self),
  ] }

  public var species: String { __data["species"] }
}
