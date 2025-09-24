final class DataLoader<Key: Hashable, Value> {
  typealias BatchLoad = (Set<Key>) async throws -> [Key: Value]
  private var batchLoad: BatchLoad

  private var cache: [Key: Result<Value?, any Error>] = [:]
  private var pendingLoads: Set<Key> = []

  init(_ batchLoad: @escaping BatchLoad) {
    self.batchLoad = batchLoad
  }

  subscript(key: Key) -> PossiblyDeferred<Value?> {
    if let cachedResult = cache[key] {
      return .immediate(cachedResult)
    }
    
    pendingLoads.insert(key)
    
    return .deferred { try await self.load(key) }
  }
  
  private func load(_ key: Key) async throws -> Value? {
    if let cachedResult = cache[key] {
      return try cachedResult.get()
    }
    
    assert(pendingLoads.contains(key))
    
    let values = try await batchLoad(pendingLoads)

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
