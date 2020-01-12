final class GraphQLFirstModifiedAtTracker: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, firstModifiedAt: Timestamp, info: GraphQLResolveInfo) throws -> Timestamp {
    return firstModifiedAt
  }

  func acceptNullValue(firstModifiedAt: Timestamp, info: GraphQLResolveInfo) -> Timestamp {
    return firstModifiedAt
  }

  func accept(list: [Timestamp], info: GraphQLResolveInfo) -> Timestamp {
    return list.min() ?? -1
  }

  func accept(fieldEntry: Timestamp, info: GraphQLResolveInfo) -> Timestamp {
    return fieldEntry
  }

  func accept(fieldEntries: [Timestamp], info: GraphQLResolveInfo) throws -> Timestamp {
    return fieldEntries.min() ?? -1
  }

  func finish(rootValue: Timestamp, info: GraphQLResolveInfo) -> GraphQLResultContext {
    return GraphQLResultContext(resultAge: Date(timeIntervalSince1970: Double(rootValue) / 1000))
  }
}
