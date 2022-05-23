@testable import Apollo
@testable import ApolloAPI

extension ApolloStore {

  public static func mock(cache: NormalizedCache = NoCache()) -> ApolloStore {
    ApolloStore(cache: cache)
  }
  
}

/// A `NormalizedCache` that does not cache any data. Used for tests that don't require testing
/// caching behavior.
public class NoCache: NormalizedCache {

  public init() { }

  public func loadRecords(forKeys keys: Set<String>) throws -> [String : Record] {
    return [:]
  }

  public func merge(records: RecordSet) throws -> Set<String> {
    return Set()
  }

  public func removeRecord(for key: String) throws { }

  public func removeRecords(matching pattern: String) throws { }

  public func clear() throws { }

}
