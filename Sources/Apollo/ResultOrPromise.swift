import Dispatch

func whenAll<Value>(_ resultsOrPromises: [ResultOrPromise<Value>], notifyOn queue: DispatchQueue = .global()) -> ResultOrPromise<[Value]> {
  onlyResults: do {
    var results: [Result<Value, Error>] = []
    for resultOrPromise in resultsOrPromises {
      guard case .result(let result) = resultOrPromise else {
        break onlyResults
      }
      results.append(result)
    }
    do {
      let values = try results.map { try $0.get() }
      return .result(.success(values))
    } catch {
      return .result(.failure(error))
    }
  }

  return .promise(Promise { (fulfill, reject) in
    let group = DispatchGroup()
    var rejected = false

    for resultOrPromise in resultsOrPromises {
      group.enter()

      resultOrPromise.andThen { value in
        group.leave()
      }.catch { error in
        reject(error)
        rejected = true
        group.leave()
      }
    }

    group.notify(queue: queue) {
      if !rejected {
        fulfill(resultsOrPromises.map { $0.result!.value! })
      }
    }
  })
}

enum ResultOrPromise<Value> {
  case result(Result<Value, Error>)
  case promise(Promise<Value>)

  init(_ body: () throws -> Value) {
    do {
      let value = try body()
      self = .result(.success(value))
    } catch {
      self = .result(.failure(error))
    }
  }

  var result: Result<Value, Error>? {
    switch self {
    case .result(let result):
      return result
    case .promise(let promise):
      return promise.result
    }
  }

  func await() throws -> Value {
    switch self {
    case .result(let result):
      return try result.get()
    case .promise(let promise):
      return try promise.await()
    }
  }

  func asPromise() -> Promise<Value> {
    switch self {
    case .result(let result):
      return Promise(resolved: result)
    case .promise(let promise):
      return promise
    }
  }

  @discardableResult func andThen(_ whenFulfilled: @escaping (Value) throws -> Void) -> ResultOrPromise<Value> {
    switch self {
    case .result(.success(let value)):
      do {
        try whenFulfilled(value)
        return .result(.success(value))
      } catch {
        return .result(.failure(error))
      }
    case .result(.failure(let error)):
      return .result(.failure(error))
    case .promise(let promise):
      return .promise(promise.andThen(whenFulfilled))
    }
  }

  @discardableResult func `catch`(_ whenRejected: @escaping (Error) throws -> Void) -> ResultOrPromise<Value> {
    switch self {
    case .result(.success(let value)):
      return .result(.success(value))
    case .result(.failure(let error)):
      do {
        try whenRejected(error)
        return .result(.failure(error))
      } catch {
        return .result(.failure(error))
      }
    case .promise(let promise):
      return .promise(promise.`catch`(whenRejected))
    }
  }

  func map<T>(_ transform: @escaping (Value) throws -> T) -> ResultOrPromise<T> {
    switch self {
    case .result(.success(let value)):
      do {
        return .result(.success(try transform(value)))
      } catch {
        return .result(.failure(error))
      }
    case .result(.failure(let error)):
      return .result(.failure(error))
    case .promise(let promise):
      return .promise(promise.map { value in
        return try transform(value)
      })
    }
  }

 func flatMap<T>(_ transform: @escaping (Value) throws -> ResultOrPromise<T>) -> ResultOrPromise<T> {
    switch self {
    case .result(.success(let value)):
      do {
        return try transform(value)
      } catch {
        return .result(.failure(error))
      }
    case .result(.failure(let error)):
      return .result(.failure(error))
    case .promise(let promise):
      return .promise(promise.flatMap { value in
        return try transform(value).asPromise()
      })
    }
  }

  func on(queue: DispatchQueue) -> ResultOrPromise<Value> {
    if case .promise(let promise) = self {
      return .promise(promise.on(queue: queue))
    } else {
      return self
    }
  }
}
