import Foundation

extension String: ApolloJSONDecodable, ApolloJSONEncodable {
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

extension Int: ApolloJSONDecodable, ApolloJSONEncodable {
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

extension Float: ApolloJSONDecodable, ApolloJSONEncodable {
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

extension Double: ApolloJSONDecodable, ApolloJSONEncodable {
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

extension Bool: ApolloJSONDecodable, ApolloJSONEncodable {
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

extension RawRepresentable where RawValue: ApolloJSONDecodable {
  public init(jsonValue value: JSONValue) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: ApolloJSONEncodable {
  public var jsonValue: JSONValue {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: ApolloJSONDecodable {
  public init(jsonValue value: JSONValue) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

// Once [conditional conformances](https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md) have been implemented, we should be able to replace these runtime type checks with proper static typing

extension Optional: ApolloJSONEncodable {
  public var jsonValue: JSONValue {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as ApolloJSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension Dictionary: ApolloJSONEncodable {
  public var jsonValue: JSONValue {
    return jsonObject
  }
  
  public var jsonObject: JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as ApolloJSONEncodable) = (key, value) {
        jsonObject[key] = value.jsonValue
      } else {
        fatalError("Dictionary is only JSONEncodable if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

extension Array: ApolloJSONEncodable {
  public var jsonValue: JSONValue {
    return map() { element -> (JSONValue) in
      if case let element as ApolloJSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

// Example custom scalar

extension URL: ApolloJSONDecodable, ApolloJSONEncodable {
  public init(jsonValue value: JSONValue) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    
    if let url = URL(string: string) {
        self = url
    } else {
        throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
  }

  public var jsonValue: JSONValue {
    return self.absoluteString
  }
}
