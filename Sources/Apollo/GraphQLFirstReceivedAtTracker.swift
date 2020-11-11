import Foundation

final class GraphQLFirstReceivedAtTracker: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> Date {
    return firstReceivedAt
  }

  func acceptNullValue(firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> Date {
    return firstReceivedAt
  }

  func accept(list: [Date], info: GraphQLResolveInfo) throws -> Date {
    return list.min() ?? .distantPast
  }

  func accept(fieldEntry: Date, info: GraphQLResolveInfo) throws -> Date {
    return fieldEntry
  }

  func accept(fieldEntries: [Date], info: GraphQLResolveInfo) throws -> Date {
    return fieldEntries.min() ?? .distantPast
  }

  func finish(rootValue: Date, info: GraphQLResolveInfo) throws -> GraphQLResultMetadata {
    return GraphQLResultMetadata(maxAge: rootValue)
  }
}
