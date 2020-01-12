final class GraphQLFirstModifiedAtTracker: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, firstModifiedAt: Date, info: GraphQLResolveInfo) throws -> Date {
    return firstModifiedAt
  }

  func acceptNullValue(firstModifiedAt: Date, info: GraphQLResolveInfo) -> Date {
    return firstModifiedAt
  }

  func accept(list: [Date], info: GraphQLResolveInfo) -> Date {
    return list.min() ?? Date(timeIntervalSince1970: 0)
  }

  func accept(fieldEntry: Date, info: GraphQLResolveInfo) -> Date {
    return fieldEntry
  }

  func accept(fieldEntries: [Date], info: GraphQLResolveInfo) throws -> Date {
    return fieldEntries.min() ?? Date(timeIntervalSince1970: 0)
  }

  func finish(rootValue: Date, info: GraphQLResolveInfo) -> GraphQLResultContext {
    return GraphQLResultContext(resultAge: rootValue)
  }
}
