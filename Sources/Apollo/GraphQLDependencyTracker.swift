final class GraphQLDependencyTracker: GraphQLResultAccumulator {
  private var dependentKeys: Set<CacheKey> = Set()

  func accept(scalar: JSONValue, info: GraphQLResolveInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func acceptNullValue(info: GraphQLResolveInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func accept(list: [Void], info: GraphQLResolveInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func accept(fieldEntry: Void, info: GraphQLResolveInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func accept(fieldEntries: [Void], info: GraphQLResolveInfo) {
  }

  func finish(rootValue: Void, info: GraphQLResolveInfo) -> Set<CacheKey> {
    return dependentKeys
  }
}
