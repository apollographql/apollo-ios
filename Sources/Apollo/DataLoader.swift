import Dispatch

final class DataLoader<Key: Hashable, Value> {
  public typealias BatchLoad = ([Key]) -> Promise<[Value]>
  typealias Load = (key: Key, fulfill: (Value) -> Void, reject: (Error) -> Void)

  private let queue: DispatchQueue

  private var batchLoad: BatchLoad

  private var cache: [Key: Promise<Value>] = [:]
  private var loads: [Load] = []

  public init(_ batchLoad: @escaping BatchLoad) {
    queue = DispatchQueue(label: "com.apollographql.DataLoader")

    self.batchLoad = batchLoad
  }

  subscript(key: Key) -> Promise<Value> {
    if let promise = cache[key] {
      return promise
    }

    let promise = Promise<Value> { fulfill, reject in
      enqueue(load: (key, fulfill, reject))
    }

    cache[key] = promise

    return promise
  }

  private func enqueue(load: Load) {
    queue.async {
      self.loads.append(load)
    }
  }

  func dispatch() {
    queue.async {
      let loads = self.loads

      if loads.isEmpty { return }

      self.loads = []

      let keys = loads.map { $0.key }

      self.batchLoad(keys).catch { error in
        loads.forEach { $0.reject(error) }
      }.andThen { values in
        for (load, value) in zip(loads, values) {
          load.fulfill(value)
        }
      }
    }
  }
}
