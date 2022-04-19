import Foundation

public class CacheTransaction {
  let schema: SchemaConfiguration.Type
  private(set) var errors: [CacheError] = []
  private var fetchedObjects: [CacheReference: Object] = [:]

  init(schema: SchemaConfiguration.Type) {
    self.schema = schema
  }

  func object(for reference: CacheReference) -> Object? {
    fetchedObjects[reference] // TODO: if not fetched yet, fetch from store
  }

  func object(withData data: [String: Any]) -> Object {
    let cacheKey = schema.cacheKey(for: data)

    if let cacheKey = cacheKey, let object = fetchedObjects[cacheKey] {
      return object
      // TODO: should merge data objects if needed?
    }

    guard let typename = data["__typename"] as? String,
          let type = schema.objectType(forTypename: typename) else {
      fatalError()
    }

    let object = type.init(transaction: self, data: data)
    if let cacheKey = cacheKey {
      fetchedObjects[cacheKey] = object
    }

    return object
  }

  func log(_ error: CacheError) {
    errors.append(error)
  }

  func log(_ error: Error) {
    // TODO
  }

//  func interface<T: Interface>(withData data: [String: Any]) -> T {
//    return T.init(object: object(withData: data))
//  }
}

struct CacheError: Error, Equatable {
  enum Reason: Error {
    case unrecognizedCacheData(_ data: Any, forType: Any.Type)
    case invalidObjectType(_ type: Object.Type, forExpectedType: Cacheable.Type)
    case invalidValue(_ value: Cacheable?, forCovariantFieldOfType: CacheEntity.Type)
    case objectNotFound(forCacheKey: CacheReference)
  }

  enum `Type` {
    case read, write
  }

  let reason: Reason
  let type: Type
  let field: String
  let object: CacheEntity?

  var message: String {
    switch self.reason {
    case let .unrecognizedCacheData(data, forType: type):
      return "Cache data '\(data)' was unrecognized for conversion to type '\(type)'."

    case let .invalidObjectType(type, forExpectedType: expectedType):
      switch expectedType {
      case is Interface.Type:
        return "Object of type '\(type)' does not implement interface '\(expectedType)'."
      case is AnyUnion.Type:
        return "Object of type '\(type)' is not a valid type for union '\(expectedType)'."
      default:
        return "Object of type '\(type)' is not a valid type for '\(expectedType)'."
      }

    case let .invalidValue(value, forCovariantFieldOfType: fieldType):
      return """
        Value '\(value ?? "nil")' is not a valid value for covariant field '\(field)'.
        Object of type '\(Swift.type(of: object))' expects value of type '\(fieldType)'.
        """

    case let .objectNotFound(forCacheKey: key):
      return "Object with cache key \(key.key) was not found in the cache."
      
    }
  }

  static func ==(lhs: CacheError, rhs: CacheError) -> Bool {
    lhs.message == rhs.message
  }
}
