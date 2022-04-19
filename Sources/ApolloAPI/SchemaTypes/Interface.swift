open class Interface: CacheEntity, Cacheable {

  final let object: Object
  final var underlyingType: Object.Type { Swift.type(of: object) } // TODO: Delete?

  public static var fields: [String : Cacheable.Type] { [:] }

  public final var _transaction: CacheTransaction { object._transaction }
  public final var data: [String: Any] { object.data }

  public required init(_ object: Object) throws {
    let objectType = type(of: object)
    guard objectType.__metadata.implements(Self.self) else {
      throw CacheError.Reason.invalidObjectType(objectType, forExpectedType: Self.self)
    }

    self.object = object
  }

  public required convenience init(_ interface: Interface) throws {
    try self.init(interface.object)
  }

  public static func value(
    with cacheData: Any,
    in transaction: CacheTransaction
  ) throws -> Self {
    switch cacheData {
    case let dataAsSelf as Self:
      return dataAsSelf

    case let object as Object:
      return try Self(object)

    case let key as CacheReference:
      guard let object = transaction.object(for: key) else {
        throw CacheError.Reason.objectNotFound(forCacheKey: key)
      }
      return try Self(object)

    case let data as [String: Any]:
      return try Self(transaction.object(withData: data))

    case let interface as Interface:
      return try Self(interface)

    default:
      throw CacheError.Reason.unrecognizedCacheData(cacheData, forType: Self.self) // TODO
    }
  }

  public final func set<T: Cacheable>(value: T?, forKey key: StaticString) throws {
    try object.set(value: value, forKey: key)
  }

}
