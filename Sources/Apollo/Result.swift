public enum Result<Value> {
  case success(Value)
  case failure(Error)
}

extension Result: CustomStringConvertible {
  public var description: String {
    switch self {
    case .success(let value):
      return "Success(\(value))"
    case .failure(let error):
      return "Error(\(error))"
    }
  }
}

extension Result {
  var value: Value? {
    switch self {
    case .success(let value):
      return value
    case .failure(_):
      return nil
    }
  }
  
  var error: Error? {
    switch self {
    case .success(_):
      return nil
    case .failure(let error):
      return error
    }
  }
  
  func valueOrError() throws -> Value {
    switch self {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }
}
