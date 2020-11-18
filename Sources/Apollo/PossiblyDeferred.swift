import Foundation

typealias Thunk<Value> = () throws -> Value

func lazilyEvaluateAll<Value, NewValue>(_ elements: [PossiblyDeferred<Value>], transform: @escaping ([Value]) throws -> NewValue) -> PossiblyDeferred<NewValue> {
  return .deferred {
    try transform(elements.map { try $0.get() })
  }
}

enum PossiblyDeferred<Value> {
  case immediate(Result<Value, Error>)
  case deferred(Thunk<Value>)
  
  init(_ body: () throws -> Value) {
    self = .immediate(Result(catching: body))
  }
  
  func get() throws -> Value {
    switch self {
    case .immediate(let result):
      return try result.get()
    case .deferred(let thunk):
      return try thunk()
    }
  }
  
  func map<NewValue>(_ transform: @escaping (Value) throws -> NewValue) -> PossiblyDeferred<NewValue> {
    switch self {
    case .immediate(let result):
      return .immediate(Result { try transform(try result.get()) })
    case .deferred(let thunk):
      return .deferred {
        try transform(try thunk())
      }
    }
  }
  
  func flatMap<NewValue>(_ transform: @escaping (Value) -> PossiblyDeferred<NewValue>) -> PossiblyDeferred<NewValue> {
    switch self {
    case .immediate(let result):
      do {
        return transform(try result.get())
      } catch {
        return .immediate(.failure(error))
      }
    case .deferred(let thunk):
      return .deferred {
        return try transform(try thunk()).get()
      }
    }
  }
  
  func mapError(_ transform: @escaping (Error) -> Error) -> PossiblyDeferred<Value> {
    switch self {
    case .immediate(let result):
      return .immediate(result.mapError(transform))
    case .deferred(let thunk):
      return .deferred {
        do {
          return try thunk()
        } catch {
          throw transform(error)
        }
      }
    }
  }
}
