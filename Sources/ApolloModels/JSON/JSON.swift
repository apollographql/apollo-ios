import Foundation

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

// MARK: Helpers

public struct JSONValueMatcher {

  public static func equals(_ lhs: Any, _ rhs: Any) -> Bool {
    if let lhs = lhs as? CacheReference, let rhs = rhs as? CacheReference {
      return lhs == rhs
    }

    if let lhs = lhs as? Array<CacheReference>, let rhs = rhs as? Array<CacheReference> {
      return lhs == rhs
    }

    let lhs = lhs as AnyObject, rhs = rhs as AnyObject
    return lhs.isEqual(rhs)
  }

}
