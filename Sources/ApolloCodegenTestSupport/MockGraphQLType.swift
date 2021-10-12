@testable import ApolloCodegenLib

public extension GraphQLObjectType {
  class func mock(
    name: String = "",
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
    name: String = "",
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
    name: String = "",
    types: [GraphQLObjectType] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.types = types
    return mock
  }
}
