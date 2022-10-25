// @generated
// This file was automatically generated and should not be edited.

import Apollo

public struct MeasurementsInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    height: Double,
    weight: Double
  ) {
    __data = InputDict([
      "height": height,
      "weight": weight
    ])
  }

  @available(*, deprecated, message: "Argument 'wingspan' is deprecated.")
  public init(
    height: Double,
    weight: Double,
    wingspan: GraphQLNullable<Double> = nil
  ) {
    __data = InputDict([
      "height": height,
      "weight": weight,
      "wingspan": wingspan
    ])
  }

  public var height: Double {
    get { __data[dynamicMember: "height"] }
    set { __data[dynamicMember: "height"] = newValue }
  }

  public var weight: Double {
    get { __data[dynamicMember: "weight"] }
    set { __data[dynamicMember: "weight"] = newValue }
  }

  @available(*, deprecated, message: "No longer valid.")
  public var wingspan: GraphQLNullable<Double> {
    get { __data[dynamicMember: "wingspan"] }
    set { __data[dynamicMember: "wingspan"] = newValue }
  }
}
