#if !COCOAPODS
import ApolloAPI
#endif

final class GraphQLDependencyTracker: GraphQLResultAccumulator {

  let requiresCacheKeyComputation: Bool = true

  private var dependentKeys: Set<CacheKey> = Set()

  func accept(scalar: JSONValue, info: FieldExecutionInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func accept(customScalar: JSONValue, info: FieldExecutionInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func acceptNullValue(info: FieldExecutionInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func acceptMissingValue(info: FieldExecutionInfo) throws -> () {
    dependentKeys.insert(info.cachePath.joined)
  }

  func accept(list: [Void], info: FieldExecutionInfo) {
    dependentKeys.insert(info.cachePath.joined)
  }

  func accept(childObject: Void, info: FieldExecutionInfo) {
  }

  func accept(fieldEntry: Void, info: FieldExecutionInfo) -> Void? {
    dependentKeys.insert(info.cachePath.joined)
    return ()
  }

  func accept(fieldEntries: [Void], info: ObjectExecutionInfo) {
  }

  func finish(rootValue: Void, info: ObjectExecutionInfo) -> Set<CacheKey> {
    return dependentKeys
  }
}
