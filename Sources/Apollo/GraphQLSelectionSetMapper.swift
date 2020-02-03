final class GraphQLSelectionSetMapper<SelectionSet: GraphQLSelectionSet>: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, info: GraphQLResolveInfo) throws -> Any? {
    guard case .scalar(let decodable) = info.fields[0].type.namedType else { preconditionFailure() }
    // This will convert a JSON value to the expected value type, which could be a custom scalar or an enum.
    return try decodable.init(jsonValue: scalar)
  }

  func acceptNullValue(info: GraphQLResolveInfo) -> Any? {
    return nil
  }

  func accept(list: [Any?], info: GraphQLResolveInfo) -> Any? {
    return list
  }

  func accept(fieldEntry: Any?, info: GraphQLResolveInfo) -> (key: String, value: Any?) {
    return (info.responseKeyForField, fieldEntry)
  }

  func accept(fieldEntries: [(key: String, value: Any?)], info: GraphQLResolveInfo) throws -> ResultMap {
    return ResultMap(fieldEntries)
  }

  func finish(rootValue: ResultMap, info: GraphQLResolveInfo) -> SelectionSet {
    return SelectionSet.init(unsafeResultMap: rootValue)
  }
}
