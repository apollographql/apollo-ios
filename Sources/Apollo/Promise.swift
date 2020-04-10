import Dispatch

func whenAll<Value>(_ promises: [Promise<Value>], notifyOn queue: DispatchQueue = .global()) -> Promise<[Value]> {
  return Promise { (fulfill, reject) in
    let group = DispatchGroup()
    var rejected = false

    for promise in promises {
      group.enter()

      promise.andThen { value in
        group.leave()
      }.catch { error in
        reject(error)
        rejected = true
        group.leave()
      }
    }

    group.notify(queue: queue) {
      if !rejected {
        fulfill(promises.map { $0.result!.value! })
      }
    }
  }
}

func firstly<T>(_ body: () throws -> Promise<T>) -> Promise<T> {
  do {
    return try body()
  } catch {
    return Promise(rejected: error)
  }
}

final class Promise<Value> {
  private let lock = Mutex()
  private var state: State<Value>

  private typealias ResultHandler<Value> = (Result<Value, Error>) -> Void
  private var resultHandlers: [ResultHandler<Value>] = []

  init(resolved result: Result<Value, Error>) {
    state = .resolved(result)
  }

  init(fulfilled value: Value) {
    state = .resolved(.success(value))
  }

  init(rejected error: Error) {
    state = .resolved(.failure(error))
  }

  init(_ body: () throws -> Value) {
    do {
      let value = try body()
      state = .resolved(.success(value))
    } catch {
      state = .resolved(.failure(error))
    }
  }

  init(_ body: (_ fulfill: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
    state = .pending

    do {
      try body(self.fulfill, self.reject)
    } catch {
      self.reject(error)
    }
  }

  var isPending: Bool {
    return lock.withLock {
      state.isPending
    }
  }

  var result: Result<Value, Error>? {
    return lock.withLock {
      switch state {
      case .pending:
        return nil
      case .resolved(let result):
        return result
      }
    }
  }

  func wait() {
    let semaphore = DispatchSemaphore(value: 0)

    whenResolved { result in
      semaphore.signal()
    }

    semaphore.wait()
  }

  func await() throws -> Value {
    let semaphore = DispatchSemaphore(value: 0)

    var result: Result<Value, Error>? = nil

    whenResolved {
      result = $0
      semaphore.signal()
    }

    semaphore.wait()

    return try result!.get()
  }

  @discardableResult func andThen(_ whenFulfilled: @escaping (Value) throws -> Void) -> Promise<Value> {
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

  @discardableResult func `catch`(_ whenRejected: @escaping (Error) throws -> Void) -> Promise<Value> {
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

  @discardableResult func finally(_ whenResolved: @escaping () -> Void) -> Promise<Value> {
    self.whenResolved { _ in whenResolved() }
    return self
  }

  func map<T>(_ transform: @escaping (Value) throws -> T) -> Promise<T> {
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

  func flatMap<T>(_ transform: @escaping (Value) throws -> Promise<T>) -> Promise<T> {
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

  func on(queue: DispatchQueue) -> Promise<Value> {
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

  private func fulfill(_ value: Value) {
    resolve(.success(value))
  }

  private func reject(_ error: Error) {
    resolve(.failure(error))
  }

  private func resolve(_ result: Result<Value, Error>) {
    lock.withLock {
      guard state.isPending else { return }

      state = .resolved(result)

      for handler in resultHandlers {
        handler(result)
      }

      resultHandlers = []
    }
  }

  private func whenResolved(_ handler: @escaping ResultHandler<Value>) {
    lock.withLock {
      // If the promise has been resolved and there are no existing result handlers,
      // there is no need to append the handler to the array first.
      if
        case .resolved(let result) = state,
        resultHandlers.isEmpty {
          handler(result)
      } else {
        resultHandlers.append(handler)
      }
    }
  }
}

private enum State<Value> {
  case pending
  case resolved(Result<Value, Error>)

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
