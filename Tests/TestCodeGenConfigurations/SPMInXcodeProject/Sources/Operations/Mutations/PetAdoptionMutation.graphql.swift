// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class PetAdoptionMutation: GraphQLMutation {
  public static let operationName: String = "PetAdoptionMutation"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation PetAdoptionMutation($input: PetAdoptionInput!) {
        adoptPet(input: $input) {
          __typename
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

  public var __variables: Variables? { ["input": input] }

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Objects.Mutation }
    public static var __selections: [Selection] { [
      .field("adoptPet", AdoptPet.self, arguments: ["input": .variable("input")]),
    ] }

    public var adoptPet: AdoptPet { __data["adoptPet"] }

    /// AdoptPet
    ///
    /// Parent Type: `Pet`
    public struct AdoptPet: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { AnimalKingdomAPI.Interfaces.Pet }
      public static var __selections: [Selection] { [
        .field("id", ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: ID { __data["id"] }
      public var humanName: String? { __data["humanName"] }
    }
  }
}
