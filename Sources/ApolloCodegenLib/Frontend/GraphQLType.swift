import JavaScriptCore

/// A GraphQL type.
public indirect enum GraphQLType: Equatable {
  case named(GraphQLNamedType)
  case nonNull(GraphQLType)
  case list(GraphQLType)

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
      self = .named(bridge.fromJSValue(jsValue))
    }
  }
}
