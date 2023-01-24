// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public class PetAdoptionMutation: GraphQLMutation {
  public static let operationName: String = "PetAdoptionMutation"
  public static let document: Apollo.DocumentType = .notPersisted(
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

  public struct Data: MyCustomProject.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Mutation }
    public static var __selections: [Apollo.Selection] { [
      .field("adoptPet", AdoptPet.self, arguments: ["input": .variable("input")]),
    ] }

    public var adoptPet: AdoptPet { __data["adoptPet"] }

    /// AdoptPet
    ///
    /// Parent Type: `Pet`
    public struct AdoptPet: MyCustomProject.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Pet }
      public static var __selections: [Apollo.Selection] { [
        .field("id", MyCustomProject.ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: MyCustomProject.ID { __data["id"] }
      public var humanName: String? { __data["humanName"] }
    }
  }
}
