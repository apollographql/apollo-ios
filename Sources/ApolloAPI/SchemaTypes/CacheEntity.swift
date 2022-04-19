public protocol CacheEntity: AnyObject, Cacheable {
  var _transaction: CacheTransaction { get }
  var data: [String: Any] { get }

  func set<T: Cacheable>(value: T?, forKey String: StaticString) throws
}
