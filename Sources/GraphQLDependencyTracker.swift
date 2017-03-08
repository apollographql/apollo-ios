final class GraphQLDependencyTracker: GraphQLResultAccumulator {
  private var dependentKeys: Set<CacheKey> = Set()
  
  func accept(scalar: JSONValue, info: GraphQLResolveInfo) {
    dependentKeys.insert(joined(path: info.cachePath))
  }
  
  func acceptNullValue(info: GraphQLResolveInfo) {
    dependentKeys.insert(joined(path: info.cachePath))
  }
  
  func accept(list: [Void], info: GraphQLResolveInfo) {
    dependentKeys.insert(joined(path: info.cachePath))
  }
  
  func accept(fieldEntry: Void, info: GraphQLResolveInfo) {
  }
  
  func accept(fieldEntries: [Void], info: GraphQLResolveInfo) {
  }
  
  func finish(rootValue: Void, info: GraphQLResolveInfo) -> Set<CacheKey> {
    return dependentKeys
  }
}
