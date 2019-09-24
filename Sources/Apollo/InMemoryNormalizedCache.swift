import Foundation

public final class InMemoryNormalizedCache: NormalizedCache {
  private var records: RecordSet

  public init(records: RecordSet = RecordSet()) {
    self.records = records
  }
  
  public func loadRecords(forKeys keys: [CacheKey],
                          callbackQueue: DispatchQueue?,
                          completion: @escaping (Result<[Record?], Error>) -> Void) {
    let records = keys.map { self.records[$0] }
    DispatchQueue.apollo_returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: .success(records))
  }
  
  public func merge(records: RecordSet,
                    callbackQueue: DispatchQueue?,
                    completion: @escaping (Result<Set<CacheKey>, Error>) -> Void) {
    let cacheKeys = self.records.merge(records: records)
    DispatchQueue.apollo_returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: .success(cacheKeys))
  }

  public func clear(callbackQueue: DispatchQueue?,
                    completion: ((Result<Void, Error>) -> Void)?) {
    self.records.clear()
    
    guard let completion = completion else {
      return
    }
    
    DispatchQueue.apollo_returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: .success(()))
  }
}
