// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension MyGraphQLSchema {
  struct DogFragment: MyGraphQLSchema.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString { """
      fragment DogFragment on Dog {
        __typename
        species
      }
      """ }

    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Objects.Dog }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { __data["species"] }
  }

}