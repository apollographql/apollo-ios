import Foundation

indirect enum GraphQLValue: Decodable, Equatable {
  case variable(String)
  case int(Int)
  case float(Double)
  case string(String)
  case boolean(Bool)
  case null
  case `enum`(String)
  case list([GraphQLValue])
  case object([String: GraphQLValue])
  
  enum CodingKeys: CodingKey {
    case kind
    case value
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let kind = try container.decode(String.self, forKey: .kind)
    
    switch kind {
    case "Variable":
      let variableName = try container.decode(String.self, forKey: .value)
      self = .variable(variableName)
    case "IntValue":
      let value = try container.decode(Int.self, forKey: .value)
      self = .int(value)
    case "FloatValue":
      let value = try container.decode(Double.self, forKey: .value)
      self = .float(value)
    case "StringValue":
      let value = try container.decode(String.self, forKey: .value)
      self = .string(value)
    case "BooleanValue":
      let value = try container.decode(Bool.self, forKey: .value)
      self = .boolean(value)
    case "NullValue":
      self = .null
    case "EnumValue":
      let value = try container.decode(String.self, forKey: .value)
      self = .enum(value)
    case "ListValue":
      let values = try container.decode([GraphQLValue].self, forKey: .value)
      self = .list(values)
    case "ObjectValue":
      let values = try container.decode([String: GraphQLValue].self, forKey: .value)
      self = .object(values)
    default:
      throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: """
        Unknown GraphQL value of kind "\(kind)"
        """)
    }
  }
}
