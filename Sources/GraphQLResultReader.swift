public typealias GraphQLResolver = (_ field: Field, _ object: JSONObject?, _ info: GraphQLResolveInfo) -> JSONValue?

public final class GraphQLResolveInfo {
  var path: [String] = []
}

protocol GraphQLResultReaderDelegate: class {
  func willResolve(field: Field, info: GraphQLResolveInfo)
  func didResolve(field: Field, info: GraphQLResolveInfo)
  func didParse(value: JSONValue)
  func didParseNull()
  func willParse(object: JSONObject)
  func didParse(object: JSONObject)
  func willParse<Element>(array: [Element])
  func willParseElement(at index: Int)
  func didParseElement(at index: Int)
  func didParse<Element>(array: [Element])
}

public final class GraphQLResultReader {
  public let variables: GraphQLMap
  let resolver: GraphQLResolver
  var delegate: GraphQLResultReaderDelegate?
  
  private var objectStack: [JSONObject] = []
  private var currentObject: JSONObject? {
    return objectStack.last
  }
  
  private var resolveInfo: GraphQLResolveInfo
  
  init(variables: GraphQLMap? = [:], resolver: @escaping GraphQLResolver) {
    self.variables = variables ?? [:]
    self.resolver = resolver
    resolveInfo = GraphQLResolveInfo()
  }
  
  /// Init a GraphQLResultReader using a JSONObject that has come from an external source
  public convenience init(rootObject: JSONObject) {
    self.init() { field, object, info in
      return (object ?? rootObject)[field.responseName]
    }
  }
  
  // MARK: -
  
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
  
  public func list<T: JSONDecodable>(for field: Field) throws -> [[T]] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: JSONDecodable>(for field: Field) throws -> [[T?]] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: JSONDecodable>(for field: Field) throws -> [T]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: JSONDecodable>(for field: Field) throws -> [T?]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: JSONDecodable>(for field: Field) throws -> [[T]]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: JSONDecodable>(for field: Field) throws -> [[T?]]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: GraphQLMappable>(for field: Field) throws -> [T] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: GraphQLMappable>(for field: Field) throws -> [T?] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: GraphQLMappable>(for field: Field) throws -> [[T]] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func list<T: GraphQLMappable>(for field: Field) throws -> [[T?]] {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: GraphQLMappable>(for field: Field) throws -> [T]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: GraphQLMappable>(for field: Field) throws -> [T?]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
    
  public func optionalList<T: GraphQLMappable>(for field: Field) throws -> [[T]]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
  
  public func optionalList<T: GraphQLMappable>(for field: Field) throws -> [[T?]]? {
    return try resolve(field: field) { try parse(array: $0) }
  }
    
  
  // MARK: -
  
  // MARK: Parsing scalar values
  
  private func parse<T: JSONDecodable>(value: JSONValue?, intoType type: T.Type = T.self) throws -> T {
    return try parse(value: required(value))
  }
  
  private func parse<T: JSONDecodable>(value: JSONValue?, intoType type: T.Type = T.self) throws -> T? {
    return try optional(value).map { try parse(value: $0) }
  }
  
  private func parse<T: JSONDecodable>(value: JSONValue, intoType type: T.Type = T.self) throws -> T {
    let decodedValue = try T.init(jsonValue: value)
    delegate?.didParse(value: value)
    return decodedValue
  }
  
  // MARK: Parsing objects
  
  private func parse<T: GraphQLMappable>(object: JSONValue?, intoType type: T.Type = T.self) throws -> T {
    return try parse(object: cast(required(object)), intoType: type)
  }
  
  private func parse<T: GraphQLMappable>(object: JSONValue?, intoType type: T.Type = T.self) throws -> T? {
    return try optional(object).map { try parse(object: cast($0), intoType: type) }
  }
  
  private func parse<T: GraphQLMappable>(object: JSONObject, intoType type: T.Type = T.self) throws -> T {
    objectStack.append(object)
    
    delegate?.willParse(object: object)
    let mappedObject = try T.init(reader: self)
    delegate?.didParse(object: object)
    
    objectStack.removeLast()
    
    return mappedObject
  }
  
  // MARK: Parsing scalar arrays
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T]? {
    return try optional(array).map {
      try parse(array: cast($0), elementType: elementType)
    }
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?]? {
    return try optional(array).map {
      try parse(array: cast($0), elementType: elementType)
    }
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T]] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T?]] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T]]? {
    return try optional(array).map {
      return try parse(array: cast(required($0)), elementType: elementType)
    }
  }
  
  private func parse<T: JSONDecodable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T?]]? {
    return try optional(array).map {
      return try parse(array: cast(required($0)), elementType: elementType)
    }
  }
  
  private func parse<T: JSONDecodable>(array: [JSONValue], elementType: T.Type = T.self) throws -> [T] {
    return try map(array: array) {
      try parse(value: $0, intoType: elementType)
    }
  }
  
  private func parse<T: JSONDecodable>(array: [JSONValue], elementType: T.Type = T.self) throws -> [T?] {
    return try map(array: array) {
      try optional($0).map {
        try parse(value: $0, intoType: elementType)
      }
    }
  }
  
  private func parse<T: JSONDecodable>(array: [JSONValue], elementType: T.Type = T.self) throws -> [[T]] {
    return try map(array: array) {
      try map(array: cast(required($0))) {
        try parse(value: required($0), intoType: elementType)
      }
    }
  }
  
  private func parse<T: JSONDecodable>(array: [JSONValue], elementType: T.Type = T.self) throws -> [[T?]] {
    return try map(array: array) {
      try map(array: cast(required($0))) {
        try parse(value: optional($0), intoType: elementType)
      }
    }
  }
  
  // MARK: Parsing object arrays
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T]? {
    return try optional(array).map { try parse(array: cast($0), elementType: elementType) }
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [T?]? {
    return try optional(array).map { try parse(array: cast($0), elementType: elementType) }
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T]] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T?]] {
    return try parse(array: cast(required(array)), elementType: elementType)
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T]]? {
    return try optional(array).map {
      return try parse(array: cast(required($0)), elementType: elementType)
    }
  }
  
  private func parse<T: GraphQLMappable>(array: JSONValue?, elementType: T.Type = T.self) throws -> [[T?]]? {
    return try optional(array).map {
      return try parse(array: cast(required($0)), elementType: elementType)
    }
  }
  
  private func parse<T: GraphQLMappable>(array: [JSONObject], elementType: T.Type) throws -> [T] {
    return try map(array: array) { try parse(object: $0, intoType: elementType) }
  }
  
  private func parse<T: GraphQLMappable>(array: [JSONObject], elementType: T.Type) throws -> [T?] {
    return try map(array: array) {
      try optional($0).map {
        try parse(object: $0, intoType: elementType)
      }
    }
  }
  
  private func parse<T: GraphQLMappable>(array: [JSONObject], elementType: T.Type = T.self) throws -> [[T]] {
    return try map(array: array) {
      try map(array: cast(required($0))) {
        try parse(object: required($0), intoType: elementType)
      }
    }
  }
  
  private func parse<T: GraphQLMappable>(array: [JSONObject], elementType: T.Type = T.self) throws -> [[T?]] {
    return try map(array: array) {
      try map(array: cast(required($0))) {
        try parse(object: optional($0), intoType: elementType)
      }
    }
  }
  
  // MARK: Helpers
  
  private func resolve<T>(field: Field, _ parse: (JSONValue?) throws -> T) throws -> T {
    resolveInfo.path.append(field.responseName)
    delegate?.willResolve(field: field, info: resolveInfo)

    do {
      let value = resolver(field, currentObject, resolveInfo)
      
      let parsedValue = try parse(value)
      
      notifyIfNil(parsedValue)
      
      resolveInfo.path.removeLast()
      delegate?.didResolve(field: field, info: resolveInfo)
      
      return parsedValue
    } catch let error as JSONDecodingError {
      throw GraphQLResultError(path: resolveInfo.path, underlying: error)
    }
  }
  
  private func map<T, Element>(array: [Element], _ parse: (Element) throws -> T) rethrows -> [T] {
    delegate?.willParse(array: array)
    
    var mappedList = [T]()
    mappedList.reserveCapacity(array.count)
    
    for (index, element) in array.enumerated() {
      resolveInfo.path.append(String(index))
      
      delegate?.willParseElement(at: index)
      let parsedValue = try parse(element)
      notifyIfNil(parsedValue)
      mappedList.append(parsedValue)
      delegate?.didParseElement(at: index)
      
      resolveInfo.path.removeLast()
    }
    
    delegate?.didParse(array: array)
    
    return mappedList
  }
  
  private func notifyIfNil<T>(_ value: T) {
    if isNil(value) {
      delegate?.didParseNull()
    }
  }
}

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
