@testable import ApolloCodegenLib

public extension GraphQLObjectType {
  class func mock(
    _ name: String = "",
    fields: [String: GraphQLField] = [:],
    interfaces: [GraphQLInterfaceType] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.fields = fields
    mock.interfaces = interfaces
    return mock
  }
}

public extension GraphQLInterfaceType {
  class func mock(
    _ name: String = "",
    fields: [String: GraphQLField] = [:],
    interfaces: [GraphQLInterfaceType] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.fields = fields
    mock.interfaces = interfaces
    return mock
  }
}

public extension GraphQLUnionType {
  class func mock(
    _ name: String = "",
    types: [GraphQLObjectType] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.types = types
    return mock
  }
}

public extension GraphQLScalarType {
  class func string() -> Self { mock(name: "String") }
  class func integer() -> Self { mock(name: "Int") }

  class func mock(name: String) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    return mock
  }
}

public extension GraphQLEnumType {
  class func skinCovering() -> Self {
    mock(name: "SkinCovering", values: ["FUR", "HAIR", "FEATHERS", "SCALES"])
  }

  class func mock(
    name: String,
    values: [String] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.values = values.map { GraphQLEnumValue.mock(name: $0) }
    return mock
  }
}

public extension GraphQLEnumValue {
  class func mock(name: String) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    return mock
  }
}
