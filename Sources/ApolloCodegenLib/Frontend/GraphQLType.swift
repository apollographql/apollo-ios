import JavaScriptCore

/// A GraphQL type.
public indirect enum GraphQLType: Hashable {
  case entity(GraphQLCompositeType)
  case scalar(GraphQLScalarType)
  case `enum`(GraphQLEnumType)
  case inputObject(GraphQLInputObjectType)
  case nonNull(GraphQLType)
  case list(GraphQLType)

  public var typeReference: String {
    switch self {
    case let .entity(type as GraphQLNamedType),
         let .scalar(type as GraphQLNamedType),
         let .enum(type as GraphQLNamedType),
         let .inputObject(type as GraphQLNamedType):
      return type.name

    case let .nonNull(ofType):
      return "\(ofType.typeReference)!"

    case let .list(ofType):
      return "[\(ofType.typeReference)]"
    }
  }

  public var namedType: GraphQLNamedType {
    switch self {
    case let .entity(type as GraphQLNamedType),
         let .scalar(type as GraphQLNamedType),
         let .enum(type as GraphQLNamedType),
         let .inputObject(type as GraphQLNamedType):
      return type

    case let .nonNull(innerType),
      let .list(innerType):
      return innerType.namedType
    }
  }

  public var innerType: GraphQLType {
    switch self {
    case .entity, .scalar, .enum, .inputObject:
      return self

    case let .nonNull(innerType),
      let .list(innerType):
      return innerType.innerType
    }
  }

  public var isNullable: Bool {
    if case .nonNull = self { return false }
    return true
  }
}

extension GraphQLType: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(typeReference)"
  }
}

extension GraphQLType: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")

    let tag = jsValue[jsValue.context.globalObject["Symbol"]["toStringTag"]].toString()

    switch tag {
    case "GraphQLNonNull":
      let ofType = jsValue["ofType"]
      self = .nonNull(GraphQLType(ofType, bridge: bridge))
    case "GraphQLList":
      let ofType = jsValue["ofType"]
      self = .list(GraphQLType(ofType, bridge: bridge))
    default:
      let namedType: GraphQLNamedType = bridge.fromJSValue(jsValue)

      switch namedType {
      case let entityType as GraphQLCompositeType:
        self = .entity(entityType)

      case let scalarType as GraphQLScalarType:
        self = .scalar(scalarType)

      case let enumType as GraphQLEnumType:
        self = .enum(enumType)

      case let inputObjectType as GraphQLInputObjectType:
        self = .inputObject(inputObjectType)

      default:
        fatalError("JSValue: \(jsValue) is not a recognized GraphQLType value.")
      }
    }
  }
}
