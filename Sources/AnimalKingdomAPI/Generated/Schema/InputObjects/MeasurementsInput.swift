// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct MeasurementsInput: InputObject {
  private(set) public var dict: InputDict

  init(
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

  var height: Float {
    get { dict["height"] }
    set { dict["height"] = newValue }
  }

  var weight: Float {
    get { dict["weight"] }
    set { dict["weight"] = newValue }
  }

  var wingspan: GraphQLNullable<Float> {
    get { dict["wingspan"] }
    set { dict["wingspan"] = newValue }
  }
}