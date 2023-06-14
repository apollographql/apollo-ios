import Foundation
import JavaScriptCore
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
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
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
      self = .list(.fromJSValue(value, bridge: bridge))
    case "ObjectValue":
      let value = jsValue["value"]

      /// The JS frontend does not do value conversions of the default values for input objects,
      /// because no other compliation is needed, these are passed through as is from `graphql-js`.
      /// We need to handle both converted object values and default values and represented by
      /// `graphql-js`.
      if !value.isUndefined {
        self = .object(.fromJSValue(value, bridge: bridge))

      } else {
        let fields = jsValue["fields"].toOrderedDictionary { field in
          (field["name"]["value"].toString(), GraphQLValue(field["value"], bridge: bridge))
        }
        self = .object(fields)
      }

    default:
      preconditionFailure("""
        Unknown GraphQL value of kind "\(kind)"
        """)
    }
  }
}
