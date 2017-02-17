public indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object(GraphQLMappable.Type)
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

public protocol GraphQLMappable {
  init(values: [Any?])
}
