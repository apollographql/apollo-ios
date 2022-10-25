// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// The input object sent when passing in a color
public struct ColorInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    red: Int,
    green: Int,
    blue: Int
  ) {
    __data = InputDict([
      "red": red,
      "green": green,
      "blue": blue
    ])
  }

  public var red: Int {
    get { __data[dynamicMember: "red"] }
    set { __data[dynamicMember: "red"] = newValue }
  }

  public var green: Int {
    get { __data[dynamicMember: "green"] }
    set { __data[dynamicMember: "green"] = newValue }
  }

  public var blue: Int {
    get { __data[dynamicMember: "blue"] }
    set { __data[dynamicMember: "blue"] = newValue }
  }
}
