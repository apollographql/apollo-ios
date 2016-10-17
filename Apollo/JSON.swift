public typealias JSONValue = Any
public typealias JSONObject = [String: Any]
public typealias JSONArray = [JSONValue]

public typealias JSONDecoder<T> = (_ jsonValue: JSONValue) throws -> T

public protocol JSONDecodable {
  init(jsonValue value: JSONValue) throws
}

public protocol JSONEncodable {
  var jsonValue: JSONValue { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue(forKey: String)
  case couldNotConvert(value: JSONValue, to: Any.Type)

  public var errorDescription: String? {
    switch self {
    case .missingValue(let key):
      return "Missing value for key: \(key)"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}
