// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// The input object sent when someone is creating a new review
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

  /// 0-5 stars
  public var stars: Int {
    get { __data[dynamicMember: "stars"] }
    set { __data[dynamicMember: "stars"] = newValue }
  }

  /// Comment about the movie, optional
  public var commentary: GraphQLNullable<String> {
    get { __data[dynamicMember: "commentary"] }
    set { __data[dynamicMember: "commentary"] = newValue }
  }

  /// Favorite color, optional
  public var favorite_color: GraphQLNullable<ColorInput> {
    get { __data[dynamicMember: "favorite_color"] }
    set { __data[dynamicMember: "favorite_color"] = newValue }
  }
}
