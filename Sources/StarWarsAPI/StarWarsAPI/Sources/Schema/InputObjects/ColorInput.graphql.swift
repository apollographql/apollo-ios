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
    get { __data.red }
    set { __data.red = newValue }
  }

  public var green: Int {
    get { __data.green }
    set { __data.green = newValue }
  }

  public var blue: Int {
    get { __data.blue }
    set { __data.blue = newValue }
  }
}
