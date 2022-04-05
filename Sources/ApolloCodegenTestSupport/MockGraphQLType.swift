@testable import ApolloCodegenLib
import OrderedCollections

public extension GraphQLCompositeType {
  class func mock(
    _ name: String = ""
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    return mock
  }
}


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
  class func boolean() -> Self { mock(name: "Boolean") }
  class func float() -> Self { mock(name: "Float") }

  class func mock(name: String) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    return mock
  }
}

public extension GraphQLType {
  static func string() -> Self { .scalar(GraphQLScalarType.mock(name: "String")) }
  static func integer() -> Self { .scalar(GraphQLScalarType.mock(name: "Int")) }
  static func boolean() -> Self { .scalar(GraphQLScalarType.mock(name: "Boolean")) }
  static func float() -> Self { .scalar(GraphQLScalarType.mock(name: "Float")) }
}

public extension GraphQLEnumType {
  class func skinCovering() -> Self {
    mock(name: "SkinCovering", values: ["FUR", "HAIR", "FEATHERS", "SCALES"])
  }

  class func relativeSize() -> Self {
    mock(name: "RelativeSize", values: ["LARGE", "AVERAGE", "SMALL"])
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

public extension GraphQLInputObjectType {
  class func mock(
    _ name: String,
    fields: [GraphQLInputField] = []
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.fields = OrderedDictionary.init(uniqueKeysWithValues: fields.map({ ($0.name, $0) }))
    return mock
  }
}

public extension GraphQLInputField {
  class func mock(
    _ name: String,
    type: GraphQLType,
    defaultValue: GraphQLValue?
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    mock.defaultValue = defaultValue
    return mock
  }
}

public extension GraphQLField {
  class func mock(
    _ name: String,
    type: GraphQLType
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    return mock
  }
}
