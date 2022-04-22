public protocol CacheEntity: AnyObject, Cacheable {
  var _transaction: CacheTransaction { get }
  var data: [String: Any] { get }
  var _object: Object { get }
}
