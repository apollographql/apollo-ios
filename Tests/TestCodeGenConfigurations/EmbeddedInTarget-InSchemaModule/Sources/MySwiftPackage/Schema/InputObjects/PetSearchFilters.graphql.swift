// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension MyGraphQLSchema {
  struct PetSearchFilters: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      hash: GraphQLNullable<String> = nil,
      species: [String],
      size: GraphQLNullable<GraphQLEnum<RelativeSize>> = nil,
      measurements: GraphQLNullable<MeasurementsInput> = nil
    ) {
      __data = InputDict([
        "hash": hash,
        "species": species,
        "size": size,
        "measurements": measurements
      ])
    }

    public var hash: GraphQLNullable<String> {
      get { __data["hash"] }
      set { __data["hash"] = newValue }
    }

    public var species: [String] {
      get { __data["species"] }
      set { __data["species"] = newValue }
    }

    public var size: GraphQLNullable<GraphQLEnum<RelativeSize>> {
      get { __data["size"] }
      set { __data["size"] = newValue }
    }

    public var measurements: GraphQLNullable<MeasurementsInput> {
      get { __data["measurements"] }
      set { __data["measurements"] = newValue }
    }
  }

}