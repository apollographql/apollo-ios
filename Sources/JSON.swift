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
