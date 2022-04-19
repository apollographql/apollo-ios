protocol AnyUnion: Cacheable {
  var object: Object { get }
}

// MARK: - UnionType
public protocol UnionType: ParentTypeConvertible {
  static var possibleTypes: [Object.Type] { get }
  var object: Object { get }

  init?(_ object: Object)
}

public enum Union<T: UnionType>: AnyUnion, Equatable {

  case `case`(T)
  case __unknown(Object)

  init(_ object: Object) throws {
    guard let value = T.init(object) else {
      let objectType = type(of: object)
      guard objectType != Object.self else {
        self = .__unknown(object)
        return
      }

      throw CacheError.Reason.invalidObjectType(type(of: object), forExpectedType: Self.self)
    }

    self = .case(value)
  }

  public static func value(
    with cacheData: Any,
    in transaction: CacheTransaction
  ) throws -> Self {
    guard let object = object(with: cacheData, in: transaction) else {
      throw CacheError.Reason.unrecognizedCacheData(cacheData, forType: T.self)
    }

    return try Self(object)
  }

  private static func object(
    with cacheData: Any,
    in transaction: CacheTransaction
  ) -> Object? {
    switch cacheData {
    case let object as Object: return object
    case let interface as Interface: return interface.object
    case let key as CacheReference: return transaction.object(for: key)
    case let data as [String: Any]: return transaction.object(withData: data)
    default: return nil
    }
  }

  var value: T? {
    switch self {
    case let .case(value): return value
    default: return nil
    }
  }

  var object: Object {
    switch self {
    case let .case(value): return value.object
    case let .__unknown(object): return object
    }
  }

  public var _transaction: CacheTransaction { object._transaction }
  public var data: [String : Any] { object.data }
}

// MARK: Union Equatable
extension Union {
  public static func ==(lhs: Union<T>, rhs: Union<T>) -> Bool {
    return lhs.object === rhs.object
  }

  public static func ==(lhs: Union<T>, rhs: T) -> Bool {
    return lhs.object === rhs.object
  }

  public static func ==(lhs: Union<T>, rhs: Object) -> Bool {
    return lhs.object === rhs
  }

  public static func !=(lhs: Union<T>, rhs: Union<T>) -> Bool {
    return lhs.object !== rhs.object
  }

  public static func !=(lhs: Union<T>, rhs: T) -> Bool {
    return lhs.object !== rhs.object
  }

  public static func !=(lhs: Union<T>, rhs: Object) -> Bool {
    return lhs.object !== rhs
  }
}

// MARK: Optional<Union<T>> Equatable

public func ==<T: UnionType>(lhs: Union<T>?, rhs: Union<T>) -> Bool {
  return lhs?.object === rhs.object
}

public func ==<T: UnionType>(lhs: Union<T>?, rhs: T) -> Bool {
  return lhs?.object === rhs.object
}

public func ==<T: UnionType>(lhs: Union<T>?, rhs: Object) -> Bool {
  return lhs?.object === rhs
}

public func !=<T: UnionType>(lhs: Union<T>?, rhs: Union<T>) -> Bool {
  return lhs?.object !== rhs.object
}

public func !=<T: UnionType>(lhs: Union<T>?, rhs: T) -> Bool {
  return lhs?.object !== rhs.object
}

public func !=<T: UnionType>(lhs: Union<T>?, rhs: Object) -> Bool {
  return lhs?.object !== rhs
}

// MARK: Union Pattern Matching Helpers
extension Union {
  public static func ~=(lhs: T, rhs: Union<T>) -> Bool {
    switch rhs {
    case let .case(rhs) where rhs.object === lhs.object: return true
    case let .__unknown(rhsObject) where rhsObject === lhs.object: return true
    default: return false
    }
  }
}

// MARK: UnionType Equatable
extension UnionType where Self: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.object === rhs.object
  }

  public static func ==(lhs: Self, rhs: Object) -> Bool {
    lhs.object === rhs
  }

  public static func !=(lhs: Self, rhs: Self) -> Bool {
    lhs.object !== rhs.object
  }

  public static func !=(lhs: Self, rhs: Object) -> Bool {
    lhs.object !== rhs
  }
}

// MARK: Optional<UnionType> Equatable

public func ==<T: UnionType>(lhs: T?, rhs: T) -> Bool {
  return lhs?.object === rhs.object
}

public func !=<T: UnionType>(lhs: T?, rhs: T) -> Bool {
  return lhs?.object !== rhs.object
}

public func ==<T: UnionType>(lhs: T?, rhs: Object) -> Bool {
  return lhs?.object === rhs
}

public func !=<T: UnionType>(lhs: T?, rhs: Object) -> Bool {
  return lhs?.object !== rhs
}
