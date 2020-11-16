#if !COCOAPODS
import ApolloCore
#endif

public typealias ResultMap = [String: Any?]

public protocol GraphQLSelectionSet {
  static var selections: [GraphQLSelection] { get }

  var resultMap: ResultMap { get }
  init(unsafeResultMap: ResultMap)
}

public extension GraphQLSelectionSet {
  init(jsonObject: JSONObject, variables: GraphQLMap? = nil) throws {
    self = try decode(selectionSet: Self.self,
                          from: jsonObject,
                          variables: variables)
  }

  var jsonObject: JSONObject {
    return resultMap.jsonObject
  }
}

extension GraphQLSelectionSet {
  public init(_ selectionSet: GraphQLSelectionSet) throws {
    try self.init(jsonObject: selectionSet.jsonObject)
  }
}

public protocol GraphQLSelection {
}

public struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?

  var responseKey: String {
    return alias ?? name
  }

  let type: GraphQLOutputType

  public init(_ name: String,
              alias: String? = nil,
              arguments: [String: GraphQLInputValue]? = nil,
              type: GraphQLOutputType) {
    self.name = name
    self.alias = alias

    self.arguments = arguments

    self.type = type
  }

  func cacheKey(with variables: [String: JSONEncodable]?) throws -> String {
    if
      let argumentValues = try arguments?.evaluate(with: variables),
      argumentValues.apollo.isNotEmpty {
        let argumentsKey = orderIndependentKey(for: argumentValues)
        return "\(name)(\(argumentsKey))"
    } else {
      return name
    }
  }
}

public indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object([GraphQLSelection])
  case nonNull(GraphQLOutputType)
  case list(GraphQLOutputType)

  var namedType: GraphQLOutputType {
    switch self {
    case .nonNull(let innerType), .list(let innerType):
      return innerType.namedType
    case .scalar, .object:
      return self
    }
  }
}

private func orderIndependentKey(for object: JSONObject) -> String {
  return object.sorted { $0.key < $1.key }.map {
    if let object = $0.value as? JSONObject {
      return "[\($0.key):\(orderIndependentKey(for: object))]"
    } else if let array = $0.value as? [JSONObject] {
      return "\($0.key):[\(array.map { orderIndependentKey(for: $0) }.joined(separator: ","))]"
    } else {
      return "\($0.key):\($0.value)"
    }
  }.joined(separator: ",")
}

public struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]

  public init(variableName: String,
              inverted: Bool,
              selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

public struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]

  public init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

public struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type

  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

public struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]

  public init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}
