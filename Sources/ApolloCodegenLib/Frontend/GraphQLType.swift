import JavaScriptCore

/// A GraphQL type.
public indirect enum GraphQLType: Equatable {
  case named(GraphQLNamedType)
  case nonNull(GraphQLType)
  case list(GraphQLType)

  /// Creates a new instance by parsing the specified type reference, resolving named types from the provided schema.
  init<S: StringProtocol>(_ typeReference: S, schema: GraphQLSchema) throws {
    if typeReference.first == "[" {
      // We're parsing a list type
      guard let closingBracketIndex = typeReference.firstIndex(of: "]") else {
        throw GraphQLTypeReferenceError.syntaxError("Missing closing bracket in type reference: \(typeReference)")
      }

      let remainingTypeReference = typeReference[typeReference.index(after: typeReference.startIndex)..<closingBracketIndex]

      self = .list(try GraphQLType(remainingTypeReference, schema: schema))
    } else if typeReference.last == "!" {
      // We're parsing a non-null type
      let remainingTypeReference = typeReference[..<typeReference.index(before: typeReference.endIndex)]

      self = .nonNull(try GraphQLType(remainingTypeReference, schema: schema))
    } else {
      // We're parsing a named type
      let typeName = String(typeReference)

      guard let type = try schema.getType(named: typeName) else {
        throw GraphQLTypeReferenceError.namedTypeNotFound("""
        Could not find GraphQL type "\(typeName)" in schema
        """)
      }

      self = .named(type)
    }
  }

  public var typeReference: String {
    switch self {
    case let .named(type):
      return type.name
    case let .nonNull(ofType):
      return "\(ofType.typeReference)!"
    case let .list(ofType):
      return "[\(ofType.typeReference)]"
    }
  }
}

extension GraphQLType: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "<GraphQLType: \(typeReference)>"
  }
}

extension GraphQLType: Decodable {
  public init(from decoder: Decoder) throws {
    guard let schema = decoder.userInfo[.graphQLSchema] as? GraphQLSchema else {
       preconditionFailure("GraphQL type decoding requires a GraphQL schema to be provided")
    }

    let container = try decoder.singleValueContainer()
    let typeReference = try container.decode(String.self)

    self = try GraphQLType(typeReference, schema: schema)
  }
}

extension GraphQLType: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isObject)

    let tag = jsValue[jsValue.context.globalObject["Symbol"]["toStringTag"]].toString()

    switch tag {
    case "GraphQLNonNull":
      let ofType = jsValue["ofType"]
      self = .nonNull(GraphQLType(ofType, bridge: bridge))
    case "GraphQLList":
      let ofType = jsValue["ofType"]
      self = .list(GraphQLType(ofType, bridge: bridge))
    default:
      self = .named(bridge.fromJSValue(jsValue))
    }
  }
}
