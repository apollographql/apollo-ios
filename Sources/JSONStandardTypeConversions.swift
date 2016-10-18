import Foundation

extension String: JSONDecodable, JSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  public var jsonValue: JSONValue {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  public var jsonValue: JSONValue {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  public var jsonValue: JSONValue {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  public var jsonValue: JSONValue {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  public var jsonValue: JSONValue {
    return self
  }
}

extension Optional where Wrapped: JSONDecodable {
  public init(jsonValue value: JSONValue) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  public init(jsonValue value: JSONValue) throws {
    let rawValue = try RawValue(jsonValue: value)
    self.init(rawValue: rawValue)!
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public var jsonValue: JSONValue {
    return rawValue.jsonValue
  }
}

extension URL: JSONDecodable, JSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  public var jsonValue: JSONValue {
    return self.absoluteString
  }
}
