// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PetAdoptionMutation: GraphQLMutation {
  public static let operationName: String = "PetAdoptionMutation"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation PetAdoptionMutation($input: PetAdoptionInput!) {
        adoptPet(input: $input) {
          __typename
          id
          humanName
        }
      }
      """#
    ))

  public var input: PetAdoptionInput

  public init(input: PetAdoptionInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("adoptPet", AdoptPet.self, arguments: ["input": .variable("input")]),
    ] }

    public var adoptPet: AdoptPet { __data["adoptPet"] }

    public init(
      adoptPet: AdoptPet
    ) {
      let objectType = AnimalKingdomAPI.Objects.Mutation
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "adoptPet": adoptPet._fieldData
      ]))
    }

    /// AdoptPet
    ///
    /// Parent Type: `Pet`
    public struct AdoptPet: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(_data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", AnimalKingdomAPI.ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: AnimalKingdomAPI.ID { __data["id"] }
      public var humanName: String? { __data["humanName"] }

      public init(
        __typename: String,
        id: AnimalKingdomAPI.ID,
        humanName: String? = nil
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            AnimalKingdomAPI.Interfaces.Pet
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "id": id,
            "humanName": humanName
        ]))
      }
    }
  }
}
