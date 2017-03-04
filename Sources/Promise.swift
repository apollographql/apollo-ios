public func whenAll<Value>(_ promises: [Promise<Value>], notifyOn queue: DispatchQueue) -> Promise<[Value]> {
  return Promise { (fulfill, reject) in
    let group = DispatchGroup()
    
    for promise in promises {
      group.enter()
      
      promise.andThen { value in
        group.leave()
      }.catch { error in
        queue.async {
          reject(error)
        }
      }
    }
    
    group.notify(queue: queue) {
      fulfill(promises.flatMap { $0.result?.value })
    }
  }
}

public func firstly<T>(_ body: () throws -> Promise<T>) -> Promise<T> {
  do {
    return try body()
  } catch {
    return Promise(rejected: error)
  }
}

public final class Promise<Value> {
  private var lock = os_unfair_lock_s()
  
  private var state: State<Value>
  
  private typealias ResultHandler<Value> = (Result<Value>) -> Void
  private var resultHandlers: [ResultHandler<Value>] = []
  
  public init(fulfilled value: Value) {
    state = .resolved(.success(value))
  }
  
  public init(rejected error: Error) {
    state = .resolved(.failure(error))
  }
  
  public init(_ body: () throws -> Value) {
    do {
      let value = try body()
      state = .resolved(.success(value))
    } catch {
      state = .resolved(.failure(error))
    }
  }
  
  public init(_ body: (_ fulfill: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
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
  
  @discardableResult public func andThen(_ whenFulfilled: @escaping (Value) throws -> Void) -> Promise<Value> {
    return Promise<Value> { fulfill, reject in
      whenResolved { result in
        switch result {
        case .success(let value):
          do {
            try whenFulfilled(value)
            fulfill(value)
          } catch {
            reject(error)
          }
        case .failure(let error):
          reject(error)
        }
      }
    }
  }
  
  @discardableResult public func `catch`(_ whenRejected: @escaping (Error) throws -> Void) -> Promise<Value> {
    return Promise<Value> { fulfill, reject in
      whenResolved { result in
        switch result {
        case .success(let value):
          fulfill(value)
        case .failure(let error):
          do {
            try whenRejected(error)
            reject(error)
          } catch {
            reject(error)
          }
        }
      }
    }
  }
  
  public func map<T>(_ transform: @escaping (Value) throws -> T) -> Promise<T> {
    return Promise<T> { fulfill, reject in
      whenResolved { result in
        switch result {
        case .success(let value):
          do {
            fulfill(try transform(value))
          } catch {
            reject(error)
          }
        case .failure(let error):
          reject(error)
        }
      }
    }
  }
  
  public func flatMap<T>(_ transform: @escaping (Value) throws -> Promise<T>) -> Promise<T> {
    return Promise<T> { fulfill, reject in
      whenResolved { result in
        switch result {
        case .success(let value):
          do {
            try transform(value).andThen(fulfill).catch(reject)
          } catch {
            reject(error)
          }
        case .failure(let error):
          reject(error)
        }
      }
    }
  }
  
  public func on(queue: DispatchQueue) -> Promise<Value> {
    return Promise<Value> { fulfill, reject in
      whenResolved { result in
        switch result {
        case .success(let value):
          queue.async {
            fulfill(value)
          }
        case .failure(let error):
          queue.async {
            reject(error)
          }
        }
      }
    }
  }
  
  public var isPending: Bool {
    return lock {
      state.isPending
    }
  }
  
  public var result: Result<Value>? {
    return lock {
      switch state {
      case .pending:
        return nil
      case .resolved(let result):
        return result
      }
    }
  }
  
  public func wait() throws -> Value {
    let semaphore = DispatchSemaphore(value: 0)
    
    var receivedResult: Result<Value>? = nil
    
    whenResolved { result in
      receivedResult = result
      semaphore.signal()
    }
    
    semaphore.wait()
    
    return try receivedResult!.valueOrThrow()
  }
  
  private func fulfill(_ value: Value) {
    resolve(.success(value))
  }
  
  private func reject(_ error: Error) {
    resolve(.failure(error))
  }
  
  private func resolve(_ result: Result<Value>) {
    lock {
      guard state.isPending else { return }
      
      state = .resolved(result)
      
      for handler in resultHandlers {
        handler(result)
      }
      
      resultHandlers = []
    }
  }
  
  private func whenResolved(_ handler: @escaping ResultHandler<Value>) {
    lock {
      // If the promise has been resolved and there are no existing result handlers,
      // there is no need to append the handler to the array first
      if case .resolved(let result) = state, resultHandlers.isEmpty {
        handler(result)
      } else {
        resultHandlers.append(handler)
      }
    }
  
  private func lock<T>(_ body: () throws -> T) rethrows -> T {
    os_unfair_lock_lock(&lock)
    defer { os_unfair_lock_unlock(&lock) }
    return try body()
  }
}

private enum State<Value> {
  case pending
  case resolved(Result<Value>)
  
  var isPending: Bool {
    if case .pending = self {
      return true
    } else {
      return false
    }
  }
}

extension State: CustomStringConvertible {
  var description: String {
    switch self {
    case .pending:
      return "Promise(Pending)"
    case .resolved(let result):
      return "Promise(\(result))"
    }
  }
}
