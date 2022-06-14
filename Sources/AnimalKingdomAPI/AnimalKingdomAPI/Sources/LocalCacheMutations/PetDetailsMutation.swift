// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct PetDetailsMutation: AnimalKingdomAPI.MutableSelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PetDetailsMutation on Pet {
      __typename
      owner {
        __typename
        firstName
      }
    }
    """ }

  public var data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
  public static var selections: [Selection] { [
    .field("owner", Owner?.self),
  ] }

  public var owner: Owner? {
    get { data["owner"] }
    set { data["owner"] = newValue }
  }

  /// Owner
  public struct Owner: AnimalKingdomAPI.MutableSelectionSet {
    public var data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Human.self) }
    public static var selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { data["firstName"] }
      set { data["firstName"] = newValue }
    }
  }
}