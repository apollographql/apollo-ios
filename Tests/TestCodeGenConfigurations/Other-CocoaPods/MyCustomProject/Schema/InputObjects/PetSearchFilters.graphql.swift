// @generated
// This file was automatically generated and should not be edited.

import Apollo

public struct PetSearchFilters: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    species: [String],
    size: GraphQLNullable<GraphQLEnum<RelativeSize>> = nil,
    measurements: GraphQLNullable<MeasurementsInput> = nil
  ) {
    __data = InputDict([
      "species": species,
      "size": size,
      "measurements": measurements
    ])
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
