import Foundation

extension String: JSONDecodable, JSONEncodable {
  /// The ``JSONDecodable`` initializer for a `String`.
  ///
  /// This initializer will accept a `jsonValue` of a `String`, `Int` or `Double`.
  /// This allows for conversion of custom scalars that are represented as any of these types to
  /// convert using the default custom scalar typealias of `String`.
  ///
  /// # See Also
  /// ``CustomScalarType``
  @inlinable public init(jsonValue value: JSONValue) throws {
    switch value.base {
    case let string as String:
        self = string
    case let int as Int:
      self = String(int)
    case let int64 as Int64:
      self = String(int64)
    case let double as Double:
      self = String(double)
    default:
        throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
  }

  @inlinable public var _jsonValue: JSONValue {
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

  @inlinable public var _jsonValue: JSONValue {
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

  @inlinable public var _jsonValue: JSONValue {
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

  @inlinable public var _jsonValue: JSONValue {
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

  @inlinable public var _jsonValue: JSONValue {
    return self
  }
}

extension EnumType {
  @inlinable public var _jsonValue: JSONValue { rawValue }
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
  @inlinable public var _jsonValue: JSONValue {
    return rawValue._jsonValue
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

extension Optional: JSONEncodable where Wrapped: JSONEncodable & Hashable {
  @inlinable public var _jsonValue: JSONValue {
    switch self {
    case .none: return NSNull()
    case let .some(value): return value._jsonValue
    }
  }
}

extension NSDictionary: JSONEncodable {
  @inlinable public var _jsonValue: JSONValue { self }
}

extension NSNull: JSONEncodable {
  @inlinable public var _jsonValue: JSONValue { self }
}

extension JSONEncodableDictionary: JSONEncodable {
  @inlinable public var _jsonValue: JSONValue { _jsonObject }

  @inlinable public var _jsonObject: JSONObject {
    mapValues(\._jsonValue)
  }
}

extension JSONObject: JSONDecodable {
  @inlinable public init(jsonValue value: JSONValue) throws {
    guard let dictionary = value as? JSONObject else {
      throw JSONDecodingError.couldNotConvert(value: value, to: JSONObject.self)
    }

    self = dictionary
  }
}

extension Array: JSONEncodable {
  @inlinable public var _jsonValue: JSONValue {
    return map { element -> JSONValue in
      if case let element as JSONEncodable = element {
        return element._jsonValue
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

  @inlinable public var _jsonValue: JSONValue {
    return self.absoluteString
  }
}
