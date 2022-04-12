// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ColorInput: InputObject {
  public private(set) var data: InputDict

  public init(_ data: InputDict) {
    self.data = data
  }

  public init(
    red: Int,
    green: Int,
    blue: Int
  ) {
    data = InputDict([
      "red": red,
      "green": green,
      "blue": blue
    ])
  }

  public var red: Int {
    get { data.red }
    set { data.red = newValue }
  }

  public var green: Int {
    get { data.green }
    set { data.green = newValue }
  }

  public var blue: Int {
    get { data.blue }
    set { data.blue = newValue }
  }
}