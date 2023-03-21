// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension MyGraphQLSchema {
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

    public var input: PetAdoptionInput

    public init(input: PetAdoptionInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: MyGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_data: DataDict) { __data = _data }

      public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("adoptPet", AdoptPet.self, arguments: ["input": .variable("input")]),
      ] }

      public var adoptPet: AdoptPet { __data["adoptPet"] }

      /// AdoptPet
      ///
      /// Parent Type: `Pet`
      public struct AdoptPet: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_data: DataDict) { __data = _data }

        public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Interfaces.Pet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", MyGraphQLSchema.ID.self),
          .field("humanName", String?.self),
        ] }

        public var id: MyGraphQLSchema.ID { __data["id"] }
        public var humanName: String? { __data["humanName"] }
      }
    }
  }

}