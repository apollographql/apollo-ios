import Foundation

public enum GraphQLOptional<T> {
    case notPresent
    case nullValue
    case value(T)
}

extension GraphQLOptional: Equatable where T: Equatable {
    public static func ==(lhs: GraphQLOptional, rhs: GraphQLOptional) -> Bool {
        switch (lhs, rhs) {
        case (.notPresent, .notPresent),
            (.nullValue, .nullValue):
            return true
        case (.value(let lhsValue), .value(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

public extension KeyedEncodingContainer {
    
    mutating func encodeGraphQLOptional<T: Codable>(_ optional: GraphQLOptional<T>, forKey key: K) throws {
        switch optional {
        case .notPresent:
            break
        case .nullValue:
            try self.encodeNil(forKey: key)
        case .value(let value):
            try self.encode(value, forKey: key)
        }
    }
}

public extension KeyedDecodingContainer {
    
    func decodeGraphQLOptional<T: Codable>(forKey key: K) throws -> GraphQLOptional<T> {
        if self.contains(key) {
            if let value = try? self.decode(T.self, forKey: key) {
                return .value(value)
            } else {
                return .nullValue
            }
        } else {
            return .notPresent
        }
    }
}
