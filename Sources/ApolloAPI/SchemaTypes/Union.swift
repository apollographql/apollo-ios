public protocol Union: Cacheable, ParentTypeConvertible {
  static var possibleTypes: [Object.Type] { get }
  var object: Object { get }

  init(_ object: Object)
}

extension Union {

  #warning("TODO: Unit Test")
  public static func value(
    with cacheData: JSONValue,
    in transaction: CacheTransaction
  ) throws -> Self {
    guard let object = object(with: cacheData, in: transaction) else {
      throw CacheError.Reason.unrecognizedCacheData(cacheData, forType: Self.self)
    }

    return Self(object)
  }

  #warning("TODO: Unit Test")
  private static func object(
    with cacheData: Any,
    in transaction: CacheTransaction
  ) -> Object? {
    switch cacheData {
    case let object as Object: return object
    case let interface as Interface: return interface._object
    case let key as CacheReference: return transaction.object(for: key)
    case let data as [String: Any]: return transaction.object(withData: data)
    default: return nil
    }
  }

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.object === rhs.object
  }

}
