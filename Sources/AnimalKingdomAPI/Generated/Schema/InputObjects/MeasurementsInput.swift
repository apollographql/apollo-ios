// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct MeasurementsInput: InputObject {
  public private(set) var dict: InputDict

  public init(
    height: Float,
    weight: Float,
    wingspan: GraphQLNullable<Float> = nil
  ) {
    dict = InputDict([
      "height": height,
      "weight": weight,
      "wingspan": wingspan
    ])
  }

  public var height: Float {
    get { dict["height"] }
    set { dict["height"] = newValue }
  }

  public var weight: Float {
    get { dict["weight"] }
    set { dict["weight"] = newValue }
  }

  public var wingspan: GraphQLNullable<Float> {
    get { dict["wingspan"] }
    set { dict["wingspan"] = newValue }
  }
}