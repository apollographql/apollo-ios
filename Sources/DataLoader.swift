public final class DataLoader<Key, Value> {
  public typealias BatchLoad = ([Key]) -> Promise<[Value]>
  typealias Load = (key: Key, fulfill: (Value) -> Void, reject: (Error) -> Void)
  
  private let queue: DispatchQueue
  
  private var batchLoad: BatchLoad
  private var loads: [Load] = []
  
  public init(_ batchLoad: @escaping BatchLoad) {
    self.batchLoad = batchLoad

    queue = DispatchQueue(label: "com.apollographql.DataLoader")
  }
  
  public func load(key: Key) -> Promise<Value> {
    return Promise { fulfill, reject in
      enqueue(load: (key, fulfill, reject))
    }
  }
  
  private func enqueue(load: Load) {
    queue.async {
      self.loads.append(load)
      
      if self.loads.count == 1 {
        self.dispatch()
      }
    }
  }
  
  private func dispatch() {
    queue.async {
      let keys = self.loads.map { $0.key }
      
      self.batchLoad(keys).andThen { values in
        // TODO: Using zip would have been the nicest solution, but it currently leads to a compiler crash. 
        // This seems to have been fixed in Xcode 8.3, so we can replace it once that is out.
        // for (load, value) in zip(loads, values) {
        for (index, value) in values.enumerated() {
          let load = self.loads[index]
          load.fulfill(value)
        }
        
        self.loads = []
      }
    }
  }
}
