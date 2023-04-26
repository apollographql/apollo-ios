@testable import ApolloCodegenLib
import OrderedCollections
import AppKit

public extension GraphQLCompositeType {
  @objc class func mock(
    _ name: String = ""
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    return mock
  }
}

public extension GraphQLObjectType {
  class override func mock(
    _ name: String = ""
  ) -> Self {
    Self.mock(name, fields: [:], interfaces: [])
  }

  class func mock(
    _ name: String = "",
    fields: [String: GraphQLField] = [:],
    interfaces: [GraphQLInterfaceType] = [],
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.fields = fields
    mock.interfaces = interfaces
    mock.documentation = documentation
    return mock
  }
}

public extension GraphQLInterfaceType {
  class override func mock(
    _ name: String = ""
  ) -> Self {
    Self.mock(name, fields: [:], interfaces: [])
  }

  class func mock(
    _ name: String = "",
    fields: [String: GraphQLField] = [:],
    interfaces: [GraphQLInterfaceType] = [],
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.fields = fields
    mock.interfaces = interfaces
    mock.documentation = documentation
    return mock
  }
}

public extension GraphQLUnionType {
  class func mock(
    _ name: String = "",
    types: [GraphQLObjectType] = [],
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.types = types
    mock.documentation = documentation
    return mock
  }
}

public extension GraphQLScalarType {
  class func string() -> Self { mock(name: "String") }
  class func integer() -> Self { mock(name: "Int") }
  class func boolean() -> Self { mock(name: "Boolean") }
  class func float() -> Self { mock(name: "Float") }

  class func mock(
    name: String,
    specifiedByURL: String? = nil,
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.specifiedByURL = specifiedByURL
    mock.documentation = documentation
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
    return self.mock(
      name: name,
      values: values.map { GraphQLEnumValue.mock(name: $0) }
    )
  }

  class func mock(
    name: String,
    values: [GraphQLEnumValue],
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.values = values
    mock.documentation = documentation
    return mock
  }
}

public extension GraphQLEnumValue {
  class func mock(
    name: String,
    deprecationReason: String? = nil,
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = Name(value: name)
    mock.deprecationReason = deprecationReason
    mock.documentation = documentation
    return mock
  }
}

public extension GraphQLInputObjectType {
  class func mock(
    _ name: String,
    fields: [GraphQLInputField] = [],
    documentation: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.fields = OrderedDictionary.init(uniqueKeysWithValues: fields.map({ ($0.name, $0) }))
    mock.documentation = documentation
    return mock
  }
}

public extension GraphQLInputField {
  class func mock(
    _ name: String,
    type: GraphQLType,
    defaultValue: GraphQLValue?,
    documentation: String? = nil,
    deprecationReason: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    mock.defaultValue = defaultValue
    mock.documentation = documentation
    mock.deprecationReason = deprecationReason
    return mock
  }
}

public extension GraphQLField {
  class func mock(
    _ name: String,
    type: GraphQLType,
    deprecationReason: String? = nil
  ) -> Self {
    let mock = Self.emptyMockObject()
    mock.name = name
    mock.type = type
    mock.deprecationReason = deprecationReason
    mock.arguments = []
    return mock
  }
}
