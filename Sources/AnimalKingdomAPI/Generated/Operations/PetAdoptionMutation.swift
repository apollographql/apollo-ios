// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class PetAdoptionMutation: GraphQLMutation {
  public let operationName: String = "PetAdoptionMutation"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation PetAdoptionMutation($input: PetAdoptionInput!) {
        adoptPet(input: $input) {
          id
          humanName
        }
      }
      """
    ))

  public var input: PetAdoptionInput

  public init(input: PetAdoptionInput) {
    self.input = input
  }

  public var variables: Variables? {
    ["input": input]
  }

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Mutation.self) }
    public static var selections: [Selection] { [
      .field("adoptPet", AdoptPet.self, arguments: ["input": .variable("input")]),
    ] }

    public var adoptPet: AdoptPet { data["adoptPet"] }

    /// AdoptPet
    public struct AdoptPet: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
      public static var selections: [Selection] { [
        .field("id", ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: ID { data["id"] }
      public var humanName: String? { data["humanName"] }
    }
  }
}