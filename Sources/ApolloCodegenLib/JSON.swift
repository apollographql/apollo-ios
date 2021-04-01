import Foundation

// MARK: - JSONValue

public enum JSONValue: Codable, Equatable {
  case bool(Bool)
  case int(Int)
  case double(Double)
  case string(String)
  case array([JSONValue])
  case dictionary([String: JSONValue])
  case null
  
  public enum JSONValueError: Error, LocalizedError {
    case invalidType
    case notADictionary
    case noKeyProvided
    case noValueForKey(_ key: String)
    
    var localizedDescription: String {
      switch self {
      case .invalidType:
        return "An invalid type was encountered trying to parse JSON"
      case .notADictionary:
        return "When trying to find a keypath, an item in the keypath was not a dictionary"
      case .noKeyProvided:
        return "A key was not provided to find the keypath"
      case .noValueForKey(let key):
        return "No value was found for the key \"\(key)\""
      }
    }
  }
  
  public static func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
    switch (lhs, rhs) {
    case (.bool(let lhsValue), .bool(let rhsValue)):
      return lhsValue == rhsValue
    case (.int(let lhsValue), .int(let rhsValue)):
      return lhsValue == rhsValue
    case (.double(let lhsValue), .double(let rhsValue)):
      return lhsValue == rhsValue
    case (.string(let lhsValue), .string(let rhsValue)):
      return lhsValue == rhsValue
    case (.array(let lhsValue), .array(let rhsValue)):
      return lhsValue == rhsValue
    case (.dictionary(let lhsValue), .dictionary(let rhsValue)):
      return lhsValue == rhsValue
    case (.null, .null):
      return true
    default:
      return false
    }
  }
  
  public func valueForKeyPath(_ keyPath: [String]) throws -> JSONValue {
    guard let currentKey = keyPath.first else {
      throw JSONValueError.noKeyProvided
    }
    
    switch self {
    case .dictionary(let dictionary):
      guard let directValue = dictionary[currentKey] else {
        throw JSONValueError.noValueForKey(currentKey)
      }

      let remainingKeys = Array(keyPath.dropFirst())
      guard !remainingKeys.isEmpty else {
        return directValue
      }

      return try directValue.valueForKeyPath(remainingKeys)
    default:
      throw JSONValueError.notADictionary
    }
  }
  
  // MARK: - Codable
  
  private struct JSONKey: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
      self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
      self.init(stringValue: "\(intValue)")
      self.intValue = intValue
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .bool(let boolValue):
      var svc = encoder.singleValueContainer()
      try svc.encode(boolValue)
    case .int(let intValue):
      var svc = encoder.singleValueContainer()
      try svc.encode(intValue)
    case .double(let doubleValue):
      var svc = encoder.singleValueContainer()
      try svc.encode(doubleValue)
    case .string(let stringValue):
      var svc = encoder.singleValueContainer()
      try svc.encode(stringValue)
    case .null:
      var svc = encoder.singleValueContainer()
      try svc.encodeNil()
    case .array(let array):
      var unkeyed = encoder.unkeyedContainer()
      for item in array {
        try unkeyed.encode(item)
      }
    case .dictionary(let dictionary):
      var keyed = encoder.container(keyedBy: JSONKey.self)
      for (key, value) in dictionary {
        guard let keyType = JSONKey(stringValue: key) else {
          throw JSONValueError.invalidType
        }
        try keyed.encode(value, forKey: keyType)
      }
    }
  }
  
  public init(from decoder: Decoder) throws {
    if let keyedContainer = try? decoder.container(keyedBy: JSONKey.self) {
      // This is a dictionary
      var dictionary = [String: JSONValue]()
      for key in keyedContainer.allKeys {
        if let boolValue = try? keyedContainer.decode(Bool.self, forKey: key) {
          dictionary[key.stringValue] = .bool(boolValue)
        } else if let intValue = try? keyedContainer.decode(Int.self, forKey: key) {
          dictionary[key.stringValue] = .int(intValue)
        } else if let doubleValue = try? keyedContainer.decode(Double.self, forKey: key) {
          dictionary[key.stringValue] = .double(doubleValue)
        } else if let stringValue = try? keyedContainer.decode(String.self, forKey: key) {
          dictionary[key.stringValue] = .string(stringValue)
        } else if let containerValue = try? keyedContainer.decode([JSONValue].self, forKey: key) {
          dictionary[key.stringValue] = .array(containerValue)
        } else if let containerValue = try? keyedContainer.decode([String: JSONValue].self, forKey: key) {
          dictionary[key.stringValue] = .dictionary(containerValue)
        } else if (try? keyedContainer.decodeNil(forKey: key)) ?? false {
          dictionary[key.stringValue] = .null
        } else {
          throw JSONValueError.invalidType
        }
      }
      
      self = .dictionary(dictionary)
    } else if var unkeyedContainer = try? decoder.unkeyedContainer() {
      // This is an array
      var array = [JSONValue]()
      
      while !unkeyedContainer.isAtEnd {
        let itemInArray = try unkeyedContainer.decode(JSONValue.self)
        array.append(itemInArray)
      }
      
      self = .array(array)
    } else if let singleValueContainer = try? decoder.singleValueContainer() {
      if let boolValue = try? singleValueContainer.decode(Bool.self) {
        self = .bool(boolValue)
      } else if let intValue = try? singleValueContainer.decode(Int.self) {
        self = .int(intValue)
      } else if let doubleValue = try? singleValueContainer.decode(Double.self) {
        self = .double(doubleValue)
      } else if let stringValue = try? singleValueContainer.decode(String.self) {
        self = .string(stringValue)
      } else if singleValueContainer.decodeNil() {
        self = .null
      } else {
        throw JSONValueError.invalidType
      }
    } else {
      throw JSONValueError.invalidType
    }
  }
}

// MARK: - Expressible by _ literal conformances

extension JSONValue: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSONValue...) {
    self = .array(elements)
  }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSONValue)...) {
    self = .dictionary([String: JSONValue](uniqueKeysWithValues: elements))
  }
}

extension JSONValue: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = Int
  
  public init(integerLiteral value: Int) {
    self = .int(value)
  }
}

extension JSONValue: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = Double

  public init(floatLiteral value: Double) {
    self = .double(value)
  }
}

extension JSONValue: ExpressibleByBooleanLiteral {
  public typealias BooleanLiteralType = Bool
  
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

extension JSONValue: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSONValue: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String
  
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}
