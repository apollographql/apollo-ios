@_spi(Internal) import ApolloAPI

public extension ScalarType {
  static var defaultMockValue: Self {
    try! .init(_jsonValue: "")
  }
}

public extension CustomScalarType {
  static var defaultMockValue: Self {
    try! .init(_jsonValue: "")
  }
}
