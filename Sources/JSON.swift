public typealias JSONValue = Any

public typealias JSONObject = [String: JSONValue]

public protocol JSONDecodable {
  init(jsonValue value: JSONValue) throws
}

public protocol JSONEncodable {
  var jsonValue: JSONValue { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}

extension JSONDecodingError: Matchable {
  public typealias Base = Error
  public static func ~=(pattern: JSONDecodingError, value: Error) -> Bool {
    guard let value = value as? JSONDecodingError else {
      return false
    }
    
    switch (value, pattern) {
    case (.missingValue, .missingValue), (.nullValue, .nullValue), (.couldNotConvert, .couldNotConvert):
      return true
    default:
      return false
    }
  }
}

// MARK: Helpers

func optional(_ optionalValue: JSONValue?) throws -> JSONValue? {
  guard let value = optionalValue else {
    throw JSONDecodingError.missingValue
  }
  
  if value is NSNull { return nil }
  
  return value
}

func required(_ optionalValue: JSONValue?) throws -> JSONValue {
  guard let value = optionalValue else {
    throw JSONDecodingError.missingValue
  }
  
  if value is NSNull {
    throw JSONDecodingError.nullValue
  }
  
  return value
}

func cast<T>(_ value: JSONValue) throws -> T {
  guard let castValue = value as? T else {
    throw JSONDecodingError.couldNotConvert(value: value, to: T.self)
  }
  return castValue
}

func equals(_ lhs: Any, _ rhs: Any) -> Bool {
  if let lhs = lhs as? Reference, let rhs = rhs as? Reference {
    return lhs == rhs
  }
  
  let lhs = lhs as AnyObject, rhs = rhs as AnyObject
  return lhs.isEqual(rhs)
}
