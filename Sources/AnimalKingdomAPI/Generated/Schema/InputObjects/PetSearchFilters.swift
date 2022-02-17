// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct PetSearchFilters: InputObject {
  public private(set) var data: InputDict

  public init(_ data: InputDict) {
    self.data = data
  }

  public init(
    species: [String],
    size: GraphQLNullable<GraphQLEnum<RelativeSize>> = nil,
    measurements: GraphQLNullable<MeasurementsInput> = nil
  ) {
    data = InputDict([
      "species": species,
      "size": size,
      "measurements": measurements
    ])
  }

  public var species: [String] {
    get { data.species }
    set { data.species = newValue }
  }

  public var size: GraphQLNullable<GraphQLEnum<RelativeSize>> {
    get { data.size }
    set { data.size = newValue }
  }

  public var measurements: GraphQLNullable<MeasurementsInput> {
    get { data.measurements }
    set { data.measurements = newValue }
  }
}