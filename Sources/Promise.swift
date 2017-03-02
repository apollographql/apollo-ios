public func whenAll<Key, Value>(valuesOf dictionary: [Key: Promise<Value>], on queue: DispatchQueue) -> Promise<[Key: Value]> {
  return Promise { (fulfill, reject) in
    var values: [Key: Value] = [:]
    
    for (key, promise) in dictionary {
      promise.then(on: queue) { value in
        values[key] = value
        
        if values.count == dictionary.count {
          fulfill(values)
        }
      }.catch(on: queue) { error in
        reject(error)
      }
    }
  }
}

public func whenAll<Value>(elementsOf array: [Promise<Value>], on queue: DispatchQueue) -> Promise<[Value]> {
  return Promise { (fulfill, reject) in
    for promise in array {
      promise.then(on: queue) { value in
        if !array.contains(where: { $0.isPending }) {
          fulfill(array.flatMap { $0.value })
        }
      }.catch(on: queue) { error in
        reject(error)
      }
    }
  }
}

public final class Promise<Value> {
  private var lock = os_unfair_lock_s()
  private var state: State<Value>
  private var handlers: [Handler<Value>] = []
  
  public init() {
    state = .pending
  }
  
  public init(fulfilled value: Value) {
    state = .fulfilled(value)
  }
  
  public init(rejected error: Error) {
    state = .rejected(error)
  }
  
  public init(_ body: () throws -> Value) {
    do {
      let value = try body()
      state = .fulfilled(value)
    } catch {
      state = .rejected(error)
    }
  }
  
  public init(_ body: @escaping (_ fulfill: @escaping (Value) -> (), _ reject: @escaping (Error) -> () ) throws -> ()) {
    state = .pending
    
    do {
      try body(self.fulfill, self.reject)
    } catch {
      self.reject(error)
    }
  }
  
  public init(on queue: DispatchQueue, _ body: @escaping (_ fulfill: @escaping (Value) -> (), _ reject: @escaping (Error) -> () ) throws -> ()) {
    state = .pending
    
    queue.async {
      do {
        try body(self.fulfill, self.reject)
      } catch {
        self.reject(error)
      }
    }
  }
  
  private func fulfill(_ value: Value) {
    setState(.fulfilled(value))
  }
  
  private func reject(_ error: Error) {
    setState(.rejected(error))
  }
  
  public func map<NewValue>(on queue: DispatchQueue, _ transform: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
    return then(on: queue, transform)
  }
  
  public func flatMap<NewValue>(on queue: DispatchQueue, _ transform: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
    return then(on: queue, transform)
  }
  
  @discardableResult public func then<T>(on queue: DispatchQueue, _ whenFulfilled: @escaping (Value) throws -> Promise<T>) -> Promise<T> {
    return Promise<T>(on: queue) { fulfill, reject in
      self.addHandler(
        queue: queue,
        whenFulfilled: { value in
          do {
            try whenFulfilled(value).then(on: queue, fulfill, reject)
          } catch let error {
            reject(error)
          }
        },
        whenRejected: reject
      )
    }
  }
  
  @discardableResult public func then<T>(on queue: DispatchQueue, _ whenFulfilled: @escaping (Value) throws -> T) -> Promise<T> {
    return then(on: queue, { value -> Promise<T> in
      do {
        return Promise<T>(fulfilled: try whenFulfilled(value))
      } catch let error {
        return Promise<T>(rejected: error)
      }
    })
  }
  
  @discardableResult private func then(on queue: DispatchQueue, _ whenFulfilled: @escaping (Value) -> (), _ whenRejected: @escaping (Error) -> () = { _ in }) -> Promise<Value> {
    _ = Promise<Value>(on: queue) { fulfill, reject in
      self.addHandler(
        queue: queue,
        whenFulfilled: { value in
          fulfill(value)
          whenFulfilled(value)
        },
        whenRejected: { error in
          reject(error)
          whenRejected(error)
        }
      )
    }
    return self
  }
  
  @discardableResult public func `catch`(on queue: DispatchQueue, _ whenRejected: @escaping (Error) throws -> ()) -> Promise<Value> {
    // return then(on: queue, { _ in }, whenRejected)
    
    return Promise<Value>(on: queue) { fulfill, reject in
      self.addHandler(
        queue: queue,
        whenFulfilled: fulfill,
        whenRejected: { error in
          do {
            try whenRejected(error)
            reject(error)
          } catch let error {
            reject(error)
          }
      })
    }
  }
  
  var isPending: Bool {
    return lock {
      state.isPending
    }
  }
  
  public var value: Value? {
    return lock {
      switch state {
      case .fulfilled(let value):
        return value
      default:
        return nil
      }
    }
  }
  
  func valueOrThrow() throws -> Value {
    return try lock {
      switch state {
      case .pending:
        preconditionFailure()
      case .fulfilled(let value):
        return value
      case .rejected(let error):
        throw error
      }
    }
  }
  
  public var error: Error? {
    return lock {
      switch state {
      case .rejected(let error):
        return error
      default:
        return nil
      }
    }
  }
  
  func wait() throws -> Value {
    let semaphore = DispatchSemaphore(value: 0)
    then(on: DispatchQueue.global(), { _ in
      semaphore.signal()
    }, { _ in
      semaphore.signal()
    })
    semaphore.wait()
    return try valueOrThrow()
  }
  
  private func setState(_ newState: State<Value>) {
    lock {
      guard state.isPending else { return }
      
      state = newState
      
      notifyHandlers()
    }
  }
  
  private func addHandler(queue: DispatchQueue, whenFulfilled: @escaping (Value) -> (), whenRejected: @escaping (Error) -> ()) {
    lock {
      let handler = Handler(queue: queue, whenFulfilled: whenFulfilled, whenRejected: whenRejected)
      handlers.append(handler)
      notifyHandlers()
    }
  }
  
  private func notifyHandlers() {
    guard !state.isPending else { return }
    for handler in handlers {
      switch state {
      case let .fulfilled(value):
        handler.notifyFulfilled(value)
      case let .rejected(error):
        handler.notifyRejected(error)
      default:
        break
      }
    }
    handlers.removeAll()
  }
  
  private func lock<T>(_ body: () throws -> T) rethrows -> T {
    os_unfair_lock_lock(&lock)
    defer { os_unfair_lock_unlock(&lock) }
    return try body()
  }
}

private enum State<Value> {
  case pending
  case fulfilled(Value)
  case rejected(Error)
  
  var isPending: Bool {
    if case .pending = self {
      return true
    } else {
      return false
    }
  }
  
  var isFulfilled: Bool {
    if case .fulfilled = self {
      return true
    } else {
      return false
    }
  }
  
  var isRejected: Bool {
    if case .rejected = self {
      return true
    } else {
      return false
    }
  }
  
  var value: Value? {
    if case let .fulfilled(value) = self {
      return value
    } else {
      return nil
    }
  }
  
  var error: Error? {
    if case let .rejected(error) = self {
      return error
    } else {
      return nil
    }
  }
}

extension State: CustomStringConvertible {
  var description: String {
    switch self {
    case .fulfilled(let value):
      return "Fulfilled (\(value))"
    case .rejected(let error):
      return "Rejected (\(error))"
    case .pending:
      return "Pending"
    }
  }
}

private struct Handler<Value> {
  let queue: DispatchQueue
  let whenFulfilled: (Value) -> ()
  let whenRejected: (Error) -> ()
  
  func notifyFulfilled(_ value: Value) {
    queue.async {
      self.whenFulfilled(value)
    }
  }
  
  func notifyRejected(_ error: Error) {
    queue.async {
      self.whenRejected(error)
    }
  }
}
