import Foundation

final class DataLoader<Key: Hashable, Value> {
  public typealias BatchLoad = (Set<Key>, UUID?) throws -> [Key: Value]
  private var batchLoad: BatchLoad

  private var cache: [Key: Result<Value?, Error>] = [:]
  private var pendingLoads: Set<Key> = []

  public init(_ batchLoad: @escaping BatchLoad) {
    self.batchLoad = batchLoad
  }

  subscript(key: Key, identifier: UUID? = nil) -> PossiblyDeferred<Value?> {
    if let cachedResult = cache[key] {
      return .immediate(cachedResult)
    }
    
    pendingLoads.insert(key)

    return .deferred { try self.load(key, identifier) }
  }
  
  private func load(_ key: Key, _ identifier: UUID?) throws -> Value? {
    if let cachedResult = cache[key] {
      return try cachedResult.get()
    }
    
    assert(pendingLoads.contains(key))
    
    let values = try batchLoad(pendingLoads, identifier)

    for key in pendingLoads {
      cache[key] = .success(values[key])
    }
    
    pendingLoads.removeAll()
        
    return values[key]
  }
  
  func removeAll() {
    cache.removeAll()
  }
}
