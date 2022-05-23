#if !COCOAPODS
import ApolloAPI
#endif

/// An accumulator that converts executed data to the correct values to create a `SelectionSet`.
final class GraphQLSelectionSetMapper<SelectionSet: AnySelectionSet>: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, info: FieldExecutionInfo) throws -> JSONValue? {
    switch info.field.type.namedType {
    case let .scalar(decodable as JSONDecodable.Type),
         let .customScalar(decodable as JSONDecodable.Type):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try (decodable.init(jsonValue: scalar) as! JSONValue)
    default:
      preconditionFailure()
    }
  }

  func acceptNullValue(info: FieldExecutionInfo) -> JSONValue? {
    return nil
  }

  func accept(list: [JSONValue?], info: FieldExecutionInfo) -> JSONValue? {
    return list
  }

  func accept(childObject: JSONObject, info: FieldExecutionInfo) throws -> JSONValue? {
    return childObject
  }

  func accept(fieldEntry: JSONValue?, info: FieldExecutionInfo) -> (key: String, value: JSONValue)? {
    guard let fieldEntry = fieldEntry else { return nil }
    return (info.responseKeyForField, fieldEntry)
  }

  func accept(
    fieldEntries: [(key: String, value: JSONValue)],
    info: ObjectExecutionInfo
  ) throws -> JSONObject {
    return .init(fieldEntries, uniquingKeysWith: { (_, last) in last })
  }

  func finish(rootValue: JSONObject, info: ObjectExecutionInfo) -> SelectionSet {
    return SelectionSet.init(data: DataDict(rootValue, variables: info.variables))
  }
}
