import Foundation

/// Lazily evaluates an array of possibly deferred values.
/// - Parameters:
///   - elements: An array of possibly deferred values
/// - Returns: A deferred array with the result of evaluating each element.
func lazilyEvaluateAll<Value>(_ elements: [PossiblyDeferred<Value>]) -> PossiblyDeferred<[Value]> {
  return .deferred {
    try elements.map { try $0.get() }
  }
}

/// A possibly deferred value that represents either an immediate success or failure value, or a deferred
/// value that is evaluated lazily when needed by invoking a throwing closure.
enum PossiblyDeferred<Value> {
  /// An immediate success or failure value, represented as a `Result` instance.
  case immediate(Result<Value, Error>)
  
  /// A deferred value that will be lazily evaluated by invoking the associated throwing closure.
  case deferred(() throws -> Value)
  
  /// Creates a new immediate result by evaluating a throwing closure, capturing the
  /// returned value as a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A throwing closure to evaluate.
  init(_ body: () throws -> Value) {
    self = .immediate(Result(catching: body))
  }
  
  /// Returns the success value as a throwing expression, evaluating a deferred value
  /// if needed.
  ///
  /// - Returns: The success value, if the instance represents a success.
  /// - Throws: The failure value, if the instance represents a failure.
  func get() throws -> Value {
    switch self {
    case .immediate(let result):
      return try result.get()
    case .deferred(let thunk):
      return try thunk()
    }
  }
  
  /// Returns a new possibly deferred result, mapping any success value using the given
  /// transformation.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `PossiblyDeferred` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
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
  
  /// Returns a new possibly deferred  result, mapping any success value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// Use this method to avoid a nested result when your transformation
  /// produces another `PossiblyDeferred` type.
  ///
  /// - Parameter transform: A closure that takes the success value of the
  ///   instance.
  /// - Returns: A `PossiblyDeferred` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a failure.
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
  
  /// Returns a new result, mapping any failure value using the given
  /// transformation.
  ///
  /// - Parameter transform: A closure that takes the failure value of the
  ///   instance.
  /// - Returns: A `PossiblyDeferred` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
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
