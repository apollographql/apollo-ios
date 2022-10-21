// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DogFragment: GraphQLAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DogFragment on Dog {
      __typename
      species
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { GraphQLAPI.Objects.Dog }
  public static var __selections: [Selection] { [
    .field("species", String.self),
  ] }

  public var species: String { __data["species"] }
}
