// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DogFragment: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DogFragment on Dog {
      __typename
      species
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Dog }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("species", String.self),
  ] }

  public var species: String { __data["species"] }

  public init(
    species: String
  ) {
    self.init(_dataDict: DataDict(data: [
      "__typename": AnimalKingdomAPI.Objects.Dog.typename,
      "species": species,
      "__fulfilled": Set([
        ObjectIdentifier(Self.self)
      ])
    ]))
  }
}
