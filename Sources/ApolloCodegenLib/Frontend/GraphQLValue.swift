import Foundation
import JXKit
import OrderedCollections

indirect enum GraphQLValue: Hashable {
  case variable(String)
  case int(Int)
  case float(Double)
  case string(String)
  case boolean(Bool)
  case null
  case `enum`(String)
  case list([GraphQLValue])
  case object(OrderedDictionary<String, GraphQLValue>)
}

extension GraphQLValue: JavaScriptValueDecodable {
  init(_ jsValue: JXValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")

    let kind: String = jsValue["kind"].toString()

    switch kind {
    case "Variable":
      self = .variable(jsValue["value"].toString())
    case "IntValue":
      self = .int(jsValue["value"].toInt())
    case "FloatValue":
      self = .float(jsValue["value"].toDouble())
    case "StringValue":
      self = .string(jsValue["value"].toString())
    case "BooleanValue":
      self = .boolean(jsValue["value"].toBool())
    case "NullValue":
      self = .null
    case "EnumValue":
      self = .enum(jsValue["value"].toString())
    case "ListValue":
      var value = jsValue["value"]
      if value.isUndefined {
        value = jsValue["values"]
      }
      self = .list(.fromJXValue(value, bridge: bridge))
    case "ObjectValue":
      self = .object(.fromJXValue(jsValue["value"], bridge: bridge))
    default:
      preconditionFailure("""
        Unknown GraphQL value of kind "\(kind)"
        """)
    }
  }
}
