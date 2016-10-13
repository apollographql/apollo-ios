// Copyright (c) 2016 Meteor Development Group, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// For some reason, moving this to another file leads to a compiler crash...
public typealias JSONDecoder<T> = (_ jsonValue: JSONValue) throws -> T

public struct GraphQLMap {
  fileprivate let jsonObject: JSONObject
  
  public init(jsonObject: JSONObject) {
    self.jsonObject = jsonObject
  }
  
  private func optionalJSONValue(forKey key: String) -> JSONValue? {
    return jsonObject[key]
  }
  
  private func jsonValue(forKey key: String) throws -> JSONValue {
    guard let value = optionalJSONValue(forKey: key) else {
      throw JSONDecodingError.missingValue(forKey: key)
    }
    return value
  }
  
  public func value<T>(forKey key: String, decoder: JSONDecoder<T>) throws -> T {
    return try decoder(jsonValue(forKey: key))
  }
  
  public func value<T: JSONDecodable>(forKey key: String) throws -> T {
    return try value(forKey: key, decoder: T.init(jsonValue:))
  }
  
  public func optionalValue<T: JSONDecodable>(forKey key: String) throws -> T? {
    guard let jsonValue = optionalJSONValue(forKey: key) else { return nil }
    return try Optional<T>.init(jsonValue: jsonValue)
  }
  
  public func list<T>(forKey key: String, decoder: JSONDecoder<T>) throws -> [T] {
    let value = try jsonValue(forKey: key)
    guard let array = value as? JSONArray else {
      throw JSONDecodingError.couldNotConvert(value: value, to: JSONArray.self)
    }
    return try array.map { try decoder($0) }
  }
  
  public func optionalList<T>(forKey key: String, decoder: JSONDecoder<T>) throws -> [T]? {
    guard let value = optionalJSONValue(forKey: key) else { return nil }
    if value is NSNull { return nil }
    
    guard let array = value as? JSONArray else {
      throw JSONDecodingError.couldNotConvert(value: value, to: JSONArray.self)
    }
    return try array.map { try decoder($0) }
  }
  
  public func list<T: JSONDecodable>(forKey key: String) throws -> [T] {
    return try list(forKey: key, decoder: T.init(jsonValue:))
  }
  
  public func optionalList<T: JSONDecodable>(forKey key: String) throws -> [T]? {
    return try optionalList(forKey: key, decoder: T.init(jsonValue:))
  }
  
  public func list<T: JSONDecodable>(forKey key: String) throws -> [T?] {
    return try list(forKey: key, decoder: Optional<T>.init(jsonValue:))
  }
  
  public func optionalList<T: JSONDecodable>(forKey key: String) throws -> [T?]? {
    return try optionalList(forKey: key, decoder: Optional<T>.init(jsonValue:))
  }
  
  public func value<T: Any>(forKey key: String, baseType: Any.Type, subTypes: [String: Any.Type]) throws -> T {
    return try value(forKey: key, decoder: polymorphicObjectDecoder(baseType: baseType, subTypes: subTypes))
  }
  
  public func optionalValue<T: Any>(forKey key: String, baseType: Any.Type, subTypes: [String: Any.Type]) throws -> T? {
    return try value(forKey: key, decoder: polymorphicObjectDecoder(baseType: baseType, subTypes: subTypes))
  }
  
  public func list<T: Any>(forKey key: String, baseType: Any.Type, subTypes: [String: Any.Type]) throws -> [T] {
    return try list(forKey: key, decoder: polymorphicObjectDecoder(baseType: baseType, subTypes: subTypes))
  }
  
  public func optionalList<T: Any>(forKey key: String, baseType: Any.Type, subTypes: [String: Any.Type]) throws -> [T]? {
    return try list(forKey: key, decoder: polymorphicObjectDecoder(baseType: baseType, subTypes: subTypes))
  }
  
  private func polymorphicObjectDecoder<T: Any>(baseType: Any.Type, subTypes: [String: Any.Type]) -> JSONDecoder<T> {
    return { (value) -> T in
      guard let jsonObject = value as? JSONObject else {
        throw JSONDecodingError.couldNotConvert(value: value, to: JSONObject.self)
      }
      
      let map = GraphQLMap(jsonObject: jsonObject)
      
      let typename: String = try map.value(forKey: "__typename")
      
      guard let ObjectType = (subTypes[typename] ?? baseType) as? GraphQLMapConvertible.Type else {
        fatalError("Expected polymorphic types to be GraphQLMapConvertible")
      }
      
      return try ObjectType.init(map: map) as! T
    }
  }
}

extension GraphQLMap: JSONEncodable {
  public var jsonValue: JSONValue {
    return jsonObject
  }
}

extension GraphQLMap: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSONEncodable?)...) {
    var jsonObject = JSONObject(minimumCapacity: elements.count)
    for case let (key, value?) in elements {
      jsonObject[key] = value.jsonValue
    }
    self.init(jsonObject: jsonObject)
  }
}

extension GraphQLMap: CustomStringConvertible {
  public var description: String {
    return jsonObject.description
  }
}

public protocol GraphQLMapConvertible: JSONDecodable {
  init(map: GraphQLMap) throws
}

public extension GraphQLMapConvertible {
  public init(jsonValue value: JSONValue) throws {
    guard let jsonObject = value as? JSONObject else {
      throw JSONDecodingError.couldNotConvert(value: value, to: JSONObject.self)
    }
    
    let map = GraphQLMap(jsonObject: jsonObject)
    try self.init(map: map)
  }
}
