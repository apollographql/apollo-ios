import Foundation

extension String: JSONDecodable, JSONEncodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    switch value.base {
    case let string as String:
        self = string
    case let int as Int:
        self = String(int)
    default:
        throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
  }

  @inlinable public var jsonValue: JSONValue {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  @inlinable public var jsonValue: JSONValue {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  @inlinable public var jsonValue: JSONValue {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  @inlinable public var jsonValue: JSONValue {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  @inlinable public var jsonValue: JSONValue {
    return self
  }
}

extension EnumType {
  @inlinable public var jsonValue: JSONValue { rawValue }
}

extension RawRepresentable where RawValue: JSONDecodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  @inlinable public var jsonValue: JSONValue {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

// Once [conditional conformances](https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md) have been implemented, we should be able to replace these runtime type checks with proper static typing

extension Optional: JSONEncodable {
  @inlinable public var jsonValue: JSONValue {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as JSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension NSDictionary: JSONEncodable {
  @inlinable public var jsonValue: JSONValue { self }
}

extension NSNull: JSONEncodable {
  @inlinable public var jsonValue: JSONValue { self }
}

extension JSONEncodableDictionary: JSONEncodable {
  @inlinable public var jsonValue: JSONValue { jsonObject }

  @inlinable public var jsonObject: JSONObject {
    mapValues(\.jsonValue)
  }
}

extension Dictionary: JSONDecodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let dictionary = value as? Dictionary else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Dictionary.self)
    }

    self = dictionary
  }
}

extension Array: JSONEncodable {
  @inlinable public var jsonValue: JSONValue {
    return map { element -> JSONValue in
      if case let element as JSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

// Example custom scalar

extension URL: JSONDecodable, JSONEncodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }

    if let url = URL(string: string) {
        self = url
    } else {
        throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
  }

  @inlinable public var jsonValue: JSONValue {
    return self.absoluteString
  }
}
