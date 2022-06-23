// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ReviewInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    stars: Int,
    commentary: GraphQLNullable<String> = nil,
    favorite_color: GraphQLNullable<ColorInput> = nil
  ) {
    __data = InputDict([
      "stars": stars,
      "commentary": commentary,
      "favorite_color": favorite_color
    ])
  }

  public var stars: Int {
    get { __data.stars }
    set { __data.stars = newValue }
  }

  public var commentary: GraphQLNullable<String> {
    get { __data.commentary }
    set { __data.commentary = newValue }
  }

  public var favorite_color: GraphQLNullable<ColorInput> {
    get { __data.favorite_color }
    set { __data.favorite_color = newValue }
  }
}