import Foundation

public typealias JSONValue = Any

public typealias JSONObject = [String: JSONValue]

public protocol JSONDecodable {
  init(jsonValue value: JSONValue) throws
}

public protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: JSONValue { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
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

func equals(_ lhs: Any, _ rhs: Any) -> Bool {
  if let lhs = lhs as? Reference, let rhs = rhs as? Reference {
    return lhs == rhs
  }
  
  let lhs = lhs as AnyObject, rhs = rhs as AnyObject
  return lhs.isEqual(rhs)
}
