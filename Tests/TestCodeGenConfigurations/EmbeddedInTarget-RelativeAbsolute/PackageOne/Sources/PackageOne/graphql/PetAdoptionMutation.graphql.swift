// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

class PetAdoptionMutation: GraphQLMutation {
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

  public var input: MySchemaModule.PetAdoptionInput

  public init(input: MySchemaModule.PetAdoptionInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MySchemaModule.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("adoptPet", AdoptPet.self, arguments: ["input": .variable("input")]),
    ] }

    public var adoptPet: AdoptPet { __data["adoptPet"] }

    /// AdoptPet
    ///
    /// Parent Type: `Pet`
    public struct AdoptPet: MySchemaModule.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Interfaces.Pet }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", MySchemaModule.ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: MySchemaModule.ID { __data["id"] }
      public var humanName: String? { __data["humanName"] }
    }
  }
}
