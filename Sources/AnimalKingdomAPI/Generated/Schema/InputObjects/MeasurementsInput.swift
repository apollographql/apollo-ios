// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct MeasurementsInput: InputObject {
  public private(set) var data: InputDict

  public init(_ data: InputDict) {
    self.data = data
  }

  public init(
    height: Float,
    weight: Float,
    wingspan: GraphQLNullable<Float> = nil
  ) {
    data = InputDict([
      "height": height,
      "weight": weight,
      "wingspan": wingspan
    ])
  }

  public var height: Float {
    get { data.height }
    set { data.height = newValue }
  }

  public var weight: Float {
    get { data.weight }
    set { data.weight = newValue }
  }

  public var wingspan: GraphQLNullable<Float> {
    get { data.wingspan }
    set { data.wingspan = newValue }
  }
}