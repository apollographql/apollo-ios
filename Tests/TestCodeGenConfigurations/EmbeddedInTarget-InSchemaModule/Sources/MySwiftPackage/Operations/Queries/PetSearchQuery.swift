// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public extension MyGraphQLSchema {
  class PetSearchQuery: GraphQLQuery {
    public static let operationName: String = "PetSearch"
    public static let document: DocumentType = .notPersisted(
      definition: .init(
        """
        query PetSearch($filters: PetSearchFilters = {species: ["Dog", "Cat"], size: SMALL, measurements: {height: 10.5, weight: 5.0}}) {
          pets(filters: $filters) {
            __typename
            id
            humanName
          }
        }
        """
      ))

    public var filters: GraphQLNullable<PetSearchFilters>

    public init(filters: GraphQLNullable<PetSearchFilters> = .init(
      PetSearchFilters(
        species: ["Dog", "Cat"],
        size: .init(.SMALL),
        measurements: .init(
          MeasurementsInput(
            height: 10.5,
            weight: 5.0
          )
        )
      )
    )) {
      self.filters = filters
    }

    public var variables: Variables? { ["filters": filters] }

    public struct Data: MyGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MyGraphQLSchema.Objects.Query }
      public static var selections: [Selection] { [
        .field("pets", [Pet].self, arguments: ["filters": .variable("filters")]),
      ] }

      public var pets: [Pet] { __data["pets"] }

      /// Pet
      ///
      /// Parent Type: `Pet`
      public struct Pet: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.Pet }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("humanName", String?.self),
        ] }

        public var id: ID { __data["id"] }
        public var humanName: String? { __data["humanName"] }
      }
    }
  }

}