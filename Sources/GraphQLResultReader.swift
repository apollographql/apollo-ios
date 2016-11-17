public struct GraphQLResultError: Error, LocalizedError {
  let path: [String]
  let underlying: Error
  
  public var pathDescription: String {
    return path.joined(separator: ".")
  }
  
  public var errorDescription: String? {
    return "Error while reading path \"\(pathDescription)\": \(underlying)"
  }
}

public final class GraphQLResultReader {
  let resolver: GraphQLResolver
  
  var objectStack: [JSONObject]
  var currentObject: JSONObject? {
    return objectStack.last
  }
  
  var resolveInfo: GraphQLResolveInfo
  
  init(resolver: @escaping GraphQLResolver) {
    self.resolver = resolver
    objectStack = []
    resolveInfo = GraphQLResolveInfo()
  }
  
  public func value<T: JSONDecodable>(for field: Field) throws -> T {
    return try resolve(field: field) { try parse(value: $0) }
  }
  
  public func optionalValue<T: JSONDecodable>(for field: Field) throws -> T? {
    return try resolve(field: field) { try parse(value: $0) }
  }
  
  public func value<T: GraphQLMappable>(for field: Field) throws -> T {
    return try resolve(field: field) { try parse(object: $0) }
  }
  
  public func optionalValue<T: GraphQLMappable>(for field: Field) throws -> T? {
    return try resolve(field: field) { try parse(object: $0) }
  }
  
  public func list<T: JSONDecodable>(for field: Field) throws -> [T] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: JSONDecodable>(for field: Field) throws -> [T?] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: JSONDecodable>(for field: Field) throws -> [T]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: JSONDecodable>(for field: Field) throws -> [T?]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: GraphQLMappable>(for field: Field) throws -> [T] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: GraphQLMappable>(for field: Field) throws -> [T?] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: GraphQLMappable>(for field: Field) throws -> [T]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: GraphQLMappable>(for field: Field) throws -> [T?]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  func parse<T: JSONDecodable>(value: JSONValue?, intoType type: T.Type = T.self) throws -> T {
    return try T.init(jsonValue: required(value))
  }
  
  func parse<T: JSONDecodable>(value: JSONValue?, intoType type: T.Type = T.self) throws -> T? {
    return try optional(value).map { try T.init(jsonValue: $0) }
  }
  
  func parse<T: GraphQLMappable>(object: JSONValue?, intoType type: T.Type = T.self) throws -> T {
    return try parse(object: cast(required(object)), intoType: type)
  }
  
  func parse<T: GraphQLMappable>(object: JSONValue?, intoType type: T.Type = T.self) throws -> T? {
    return try optional(object).map { try parse(object: cast($0), intoType: type) }
  }
  
  func parse<T: GraphQLMappable>(object: JSONObject, intoType type: T.Type = T.self) throws -> T {
    objectStack.append(object)
    let mappedObject = try T.init(reader: self)
    objectStack.removeLast()
    return mappedObject
  }
  
  func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T]? {
    return try optional(array).map { try parse(array: cast($0), elementType: elementType) }
  }
  
  func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?]? {
    return try optional(array).map { try parse(array: cast($0), elementType: elementType) }
  }
  
  func parse<T: JSONDecodable>(array: [JSONValue], elementType: T.Type = T.self) throws -> [T] {
    return try map(array: array) { try parse(value: $0, intoType: elementType) }
  }
  
  func parse<T: JSONDecodable>(array: [JSONValue], elementType: T.Type = T.self) throws -> [T?] {
    return try map(array: array) {
      try optional($0).map {
        try parse(value: $0, intoType: elementType)
      }
    }
  }
  
  func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T]? {
    return try optional(array).map { try parse(array: cast($0), elementType: elementType) }
  }
  
  func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?]? {
    return try optional(array).map { try parse(array: cast($0), elementType: elementType) }
  }
  
  func parse<T: GraphQLMappable>(array: [JSONObject], elementType: T.Type) throws -> [T] {
    return try map(array: array) { try parse(object: $0, intoType: elementType) }
  }
  
  func parse<T: GraphQLMappable>(array: [JSONObject], elementType: T.Type) throws -> [T?] {
    return try map(array: array) {
      try optional($0).map {
        try parse(object: $0, intoType: elementType)
      }
    }
  }
  
  private func resolve<T>(field: Field, _ body: (JSONValue?) throws -> T) rethrows -> T {
    resolveInfo.path.append(field.responseName)
    defer {
      resolveInfo.path.removeLast()
    }
    do {
      let value = resolver(field, currentObject, resolveInfo)
      return try body(value)
    } catch let error as JSONDecodingError {
      throw GraphQLResultError(path: resolveInfo.path, underlying: error)
    }
  }
  
  private func map<T, Element>(array: [Element], _ transform: (Element) throws -> T) rethrows -> [T] {
    var mappedList = [T]()
    mappedList.reserveCapacity(array.count)
    
    for (index, element) in array.enumerated() {
      resolveInfo.path.append(String(index))
      mappedList.append(try transform(element))
      resolveInfo.path.removeLast()
    }
    
    return mappedList
  }
}

private func optional(_ optionalValue: JSONValue?) throws -> JSONValue? {
  guard let value = optionalValue else {
    return nil
  }
  
  if value is NSNull { return nil }
  
  return value
}

private func required(_ optionalValue: JSONValue?) throws -> JSONValue {
  guard let value = optionalValue else {
    throw JSONDecodingError.missingValue
  }
  
  if value is NSNull {
    throw JSONDecodingError.nullValue
  }
  
  return value
}

private func cast<T>(_ value: JSONValue) throws -> T {
  guard let castValue = value as? T else {
    throw JSONDecodingError.couldNotConvert(value: value, to: T.self)
  }
  return castValue
}
