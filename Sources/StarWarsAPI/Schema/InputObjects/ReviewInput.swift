// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ReviewInput: InputObject {
  public private(set) var data: InputDict

  public init(_ data: InputDict) {
    self.data = data
  }

  public init(
    stars: Int,
    commentary: GraphQLNullable<String> = nil,
    favorite_color: GraphQLNullable<ColorInput> = nil
  ) {
    data = InputDict([
      "stars": stars,
      "commentary": commentary,
      "favorite_color": favorite_color
    ])
  }

  public var stars: Int {
    get { data.stars }
    set { data.stars = newValue }
  }

  public var commentary: GraphQLNullable<String> {
    get { data.commentary }
    set { data.commentary = newValue }
  }

  public var favorite_color: GraphQLNullable<ColorInput> {
    get { data.favorite_color }
    set { data.favorite_color = newValue }
  }
}