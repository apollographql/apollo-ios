import Foundation

public final class InMemoryNormalizedCache: NormalizedCache {
  private var records: RecordSet
  private let recordsLock = NSRecursiveLock()

  public init(records: RecordSet = .init()) {
    self.records = records
  }

  public func loadRecords(forKeys keys: [CacheKey],
                          callbackQueue: DispatchQueue?,
                          completion: @escaping (Result<[Record?], Error>) -> Void) {
    let records = self.threadSafe { keys.map{ self.records[$0] } }
    DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: .success(records))
  }

  public func merge(records: RecordSet,
                    callbackQueue: DispatchQueue?,
                    completion: @escaping (Result<Set<CacheKey>, Error>) -> Void) {
    let cacheKeys = self.threadSafe { self.records.merge(records: records) }
    DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: .success(cacheKeys))
  }

  public func clear(
    _ clearingPolicy: CacheClearingPolicy,
    callbackQueue: DispatchQueue?,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    self.clearImmediately(clearingPolicy)
    DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: .success(()))
  }

  public func clearImmediately(_ clearingPolicy: CacheClearingPolicy) {
    self.threadSafe { self.records.clear(clearingPolicy) }
  }

  private func threadSafe<Result>(_ operation: () -> Result) -> Result {
    self.recordsLock.lock()
    let result = operation()
    self.recordsLock.unlock()
    return result
  }
}
