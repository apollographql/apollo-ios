// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct MeasurementsInput: InputObject {
  public private(set) var data: InputDict

  public init(_ data: InputDict) {
    self.data = data
  }

  public init(
    height: Double,
    weight: Double,
    wingspan: GraphQLNullable<Double> = nil
  ) {
    data = InputDict([
      "height": height,
      "weight": weight,
      "wingspan": wingspan
    ])
  }

  public var height: Double {
    get { data.height }
    set { data.height = newValue }
  }

  public var weight: Double {
    get { data.weight }
    set { data.weight = newValue }
  }

  public var wingspan: GraphQLNullable<Double> {
    get { data.wingspan }
    set { data.wingspan = newValue }
  }
}