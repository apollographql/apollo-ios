import Foundation

// MARK: - JSONValue

public enum JSONValue: Equatable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([JSONContainer])
    case dictionary([String: JSONContainer])
    case null
    
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
}

// MARK: - JSONContainer

public struct JSONContainer: Codable, Equatable {
    
    public static func ==(lhs: JSONContainer, rhs: JSONContainer) -> Bool {
        return lhs.value == rhs.value
    }

    public enum JSONContainerError: Error {
        case invalidType
        case notADictionary
        case noKeyProvided
        case noValueForKey(_ key: String)
    }
    
    public let value: JSONValue
    
    public init(value: JSONValue) {
        self.value = value
    }
    
    public func value(for key: String) throws -> JSONValue {
        return try self.valueForKeyPath(keyPath: [key])
    }
    
    public func valueForKeyPath(keyPath: [String]) throws -> JSONValue {
        guard let currentKey = keyPath.first else {
            throw JSONContainerError.noKeyProvided
        }
        
        switch self.value {
        case .dictionary(let dictionary):
            guard let directValue = dictionary[currentKey] else {
                throw JSONContainerError.noValueForKey(currentKey)
            }
            
            let remainingKeys = Array(keyPath.dropFirst())
            guard !remainingKeys.isEmpty else {
                return directValue.value
            }
            
            return try directValue.valueForKeyPath(keyPath: remainingKeys)
        default:
            throw JSONContainerError.notADictionary
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
        switch self.value {
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
                    throw JSONContainerError.invalidType
                }
                try keyed.encode(value, forKey: keyType)
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let keyedContainer = try? decoder.container(keyedBy: JSONKey.self) {
            // This is a dictionary
            var dictionary = [String: JSONContainer]()
            for key in keyedContainer.allKeys {
                if let boolValue = try? keyedContainer.decode(Bool.self, forKey: key) {
                    dictionary[key.stringValue] =  JSONContainer(value: .bool(boolValue))
                } else if let intValue = try? keyedContainer.decode(Int.self, forKey: key) {
                    dictionary[key.stringValue] = JSONContainer(value: .int(intValue))
                } else if let doubleValue = try? keyedContainer.decode(Double.self, forKey: key) {
                    dictionary[key.stringValue] = JSONContainer(value: .double(doubleValue))
                } else if let stringValue = try? keyedContainer.decode(String.self, forKey: key) {
                    dictionary[key.stringValue] = JSONContainer(value: .string(stringValue))
                } else if let containerValue = try? keyedContainer.decode(JSONContainer.self, forKey: key) {
                    dictionary[key.stringValue] = containerValue
                } else if (try? keyedContainer.decodeNil(forKey: key)) ?? false {
                    dictionary[key.stringValue] = JSONContainer(value: .null)
                } else {
                    throw JSONContainerError.invalidType
                }
            }
            
            self.value = .dictionary(dictionary)
        } else if var unkeyedContainer = try? decoder.unkeyedContainer() {
            // This is an array
            var array = [JSONContainer]()
            
            while !unkeyedContainer.isAtEnd {
                let itemInArray = try unkeyedContainer.decode(JSONContainer.self)
                array.append(itemInArray)
            }
            
            self.value = .array(array)
        } else if let singleValueContainer = try? decoder.singleValueContainer() {
            if let boolValue = try? singleValueContainer.decode(Bool.self) {
                self.value = .bool(boolValue)
            } else if let intValue = try? singleValueContainer.decode(Int.self) {
                self.value = .int(intValue)
            } else if let doubleValue = try? singleValueContainer.decode(Double.self) {
                self.value = .double(doubleValue)
            } else if let stringValue = try? singleValueContainer.decode(String.self) {
                self.value = .string(stringValue)
            } else if singleValueContainer.decodeNil() {
                self.value = .null
            } else {
                throw JSONContainerError.invalidType
            }
        } else {
            throw JSONContainerError.invalidType
        }
    }
}
